#!/usr/bin/env ruby
# frozen_string_literal: true

# apply-extras.rb - propagate the active tinty (base16/base24) scheme into
# sketchybar, OmniWM, nushell and workmux, none of which tinty can theme
# natively.
#
#   * sketchybar: writes ~/.config/sketchybar/tinty_palette.lua (a Lua table of
#     0xAARRGGBB colours) and reloads the bar. settings.lua overlays it onto its
#     gruvbox/colors tables, falling back to the hardcoded values when absent.
#   * OmniWM: rewrites the RGB components of a handful of colour tables in
#     ~/.config/omniwm/settings.toml in place (floats, 0.0-1.0). alpha and every
#     other key are left byte-for-byte untouched; OmniWM live-reloads the file.
#   * nushell: writes ~/.config/nushell/autoload/tinty_colors.nu (a
#     $env.config.color_config record). Nushell reads it at startup, so open
#     shells need a restart (or `source` the file) to pick up a new scheme.
#   * workmux: overlays accent/success/warning/danger onto ~/.config/workmux/
#     config.yaml's `theme.custom`, keeping whatever preset `theme.scheme` is
#     already set to. workmux live-reloads its config, so the sidebar recolours
#     immediately.
#
# Source of truth is the scheme YAML tinty already vendors under
# <data-dir>/repos/schemes/<system>/<slug>.yaml, so no rendered config is parsed.
#
# Usage: apply-extras.rb [scheme]     (scheme defaults to `tinty current`)
# Invoked automatically by the `tinty` fish wrapper after `apply` / `cycle`.

require 'yaml'
require 'fileutils'

# --- which palette slot drives the "active/accent" colour -----------------
# base16 convention: 08 red, 09 orange, 0A yellow, 0B green, 0C cyan,
# 0D blue, 0E magenta, 0F brown. Change this one line to restyle the accent.
ACCENT = 'base0D'

# OmniWM colour table -> palette slot. Keys are exact settings.toml headers.
OMNIWM_MAP = {
  '[borders.color]'                   => ACCENT,   # focused window border (solid; unused while the gradient is on)
  '[borders.gradient.start]'          => ACCENT,   # focused border gradient, start
  '[borders.gradient.end]'            => 'base0C', # focused border gradient, end
  '[workspaceBar.accentColor]'        => ACCENT,   # workbar focused-workspace border
  '[workspaceBar.textColor]'          => 'base05', # workbar label text
  '[overview.backdrop]'               => 'base00', # overview background
  '[overview.windowBorders.normal]'   => 'base03', # overview: unfocused
  '[overview.windowBorders.selected]' => ACCENT,   # overview: selected
  '[overview.windowBorders.hovered]'  => 'base0A'  # overview: hovered
}.freeze

# nushell color_config key -> palette slot, or [slot, attr]. Slot roles: 05 fg,
# 03 muted, 08 red, 0A yellow, 0B green, 0C cyan, 0D blue, 0E magenta.
NU_BOLD = 'b'
NU_MAP = {
  separator: 'base03', leading_trailing_space_bg: 'base00', header: ['base0C', NU_BOLD],
  empty: 'base0D', bool: 'base0C', int: 'base0A', filesize: 'base0B', duration: 'base0A',
  date: 'base0E', range: 'base05', float: 'base0A', string: 'base05', nothing: 'base03',
  binary: 'base0D', 'cell-path': 'base05', row_index: ['base0C', NU_BOLD], record: 'base05',
  list: 'base05', block: 'base05', hints: 'base03',
  shape_and: ['base0D', NU_BOLD], shape_binary: ['base0D', NU_BOLD], shape_block: ['base0D', NU_BOLD],
  shape_bool: 'base0C', shape_closure: ['base0B', NU_BOLD], shape_custom: 'base0B',
  shape_datetime: ['base0C', NU_BOLD], shape_directory: 'base0C', shape_external: 'base0C',
  shape_external_resolved: ['base0C', NU_BOLD], shape_externalarg: ['base0B', NU_BOLD],
  shape_filepath: 'base0C', shape_flag: ['base0D', NU_BOLD], shape_float: ['base0A', NU_BOLD],
  shape_garbage: ['base08', NU_BOLD], shape_glob_interpolation: ['base0C', NU_BOLD],
  shape_globpattern: ['base0C', NU_BOLD], shape_int: ['base0A', NU_BOLD],
  shape_internalcall: ['base0C', NU_BOLD], shape_keyword: ['base0D', NU_BOLD],
  shape_list: ['base0C', NU_BOLD], shape_literal: 'base0D', shape_match_pattern: 'base0B',
  shape_nothing: 'base0C', shape_operator: 'base0A', shape_or: ['base0D', NU_BOLD],
  shape_pipe: ['base0D', NU_BOLD], shape_range: ['base0A', NU_BOLD], shape_record: ['base0C', NU_BOLD],
  shape_redirection: ['base0D', NU_BOLD], shape_signature: ['base0B', NU_BOLD], shape_string: 'base0B',
  shape_string_interpolation: ['base0C', NU_BOLD], shape_table: ['base0D', NU_BOLD],
  shape_variable: 'base0E', shape_vardecl: 'base0E'
}.freeze

# workmux theme.custom key -> palette slot. Overlaid on whichever preset
# `theme.scheme` is already set to; unlisted keys (border, dimmed, etc.) keep
# the preset's own colours.
WORKMUX_CUSTOM = {
  'accent'  => ACCENT,
  'success' => 'base0B',
  'warning' => 'base0A',
  'danger'  => 'base08'
}.freeze

RGB_INDEX = { 'red' => 0, 'green' => 1, 'blue' => 2 }.freeze

def env_dir(var, default)
  val = ENV[var]
  val.nil? || val.empty? ? File.expand_path(default) : val
end

def config_home
  env_dir('XDG_CONFIG_HOME', '~/.config')
end

def data_home
  env_dir('XDG_DATA_HOME', '~/.local/share')
end

def current_scheme
  return ARGV[0] unless ARGV[0].nil? || ARGV[0].empty?

  out = `tinty current 2>/dev/null`.lines.first.to_s.strip
  abort 'apply-extras: could not determine scheme (`tinty current` empty)' if out.empty?
  out
end

# "base16-isotope" -> ["base16", "isotope"]; slugs may contain dashes.
def split_scheme(name)
  system, slug = name.split('-', 2)
  abort "apply-extras: malformed scheme name #{name.inspect}" if slug.nil? || slug.empty?

  [system, slug]
end

def load_palette(system, slug)
  path = File.join(data_home, 'tinted-theming', 'tinty', 'repos', 'schemes', system, "#{slug}.yaml")
  abort "apply-extras: scheme file not found: #{path} (try `tinty update`)" unless File.file?(path)

  palette = (YAML.safe_load(File.read(path)) || {})['palette'] || {}
  abort "apply-extras: #{path} has no palette" if palette.empty?

  palette.each_with_object({}) do |(slot, value), acc|
    hex = value.to_s.delete_prefix('#')
    acc[slot] = [hex[0, 2], hex[2, 2], hex[4, 2]].map { |c| c.to_i(16) } if hex =~ /\A\h{6}\z/
  end
end

def atomic_write(path, contents)
  path = File.realpath(path) if File.symlink?(path) # renaming over a stowed symlink would replace it
  tmp = "#{path}.tinty-tmp-#{Process.pid}"
  File.write(tmp, contents)
  FileUtils.mv(tmp, path)
end

# 0..255 int -> trimmed 0.0-1.0 float literal, e.g. 22 -> "0.086275", 0 -> "0.0"
def fmt_float(int255)
  s = format('%.6f', int255 / 255.0).sub(/(\.\d*?)0+\z/, '\1')
  s.end_with?('.') ? "#{s}0" : s
end

# --- sketchybar ----------------------------------------------------------------
def write_sketchybar(palette, scheme)
  path = File.join(config_home, 'sketchybar', 'tinty_palette.lua')
  return warn "apply-extras: #{File.dirname(path)} missing, skipping sketchybar" unless Dir.exist?(File.dirname(path))

  rows = palette.sort.map do |slot, (r, g, b)|
    format('  %<slot>-7s = 0x%<a>02x%<r>02x%<g>02x%<b>02x,', slot: slot, a: 255, r: r, g: g, b: b)
  end
  atomic_write(path, <<~LUA)
    -- Generated by tinty/hooks/apply-extras.rb - do not edit.
    -- scheme: #{scheme}
    return {
    #{rows.join("\n")}
    }
  LUA

  reloaded = system('command -v sketchybar >/dev/null 2>&1') && system('sketchybar --reload')
  puts "apply-extras: sketchybar -> #{path}#{' (reloaded)' if reloaded}"
end

# --- OmniWM ------------------------------------------------------------------
def patch_omniwm_lines(lines, palette)
  header = nil
  touched = []
  patched = lines.map do |line|
    stripped = line.strip
    header = stripped if stripped.start_with?('[') && stripped.end_with?(']')
    slot = OMNIWM_MAP[header]
    next line unless slot && line =~ /\A(\s*)(red|green|blue)(\s*=\s*).*?(\r?\n?)\z/

    touched << header
    eol = Regexp.last_match(4)
    "#{Regexp.last_match(1)}#{Regexp.last_match(2)}#{Regexp.last_match(3)}" \
      "#{fmt_float(palette.fetch(slot)[RGB_INDEX[Regexp.last_match(2)]])}#{eol.empty? ? "\n" : eol}"
  end
  [patched, touched.uniq]
end

def write_omniwm(palette)
  path = File.join(config_home, 'omniwm', 'settings.toml')
  return warn "apply-extras: #{path} not found, skipping OmniWM" unless File.file?(path)

  missing = OMNIWM_MAP.values.uniq.reject { |slot| palette.key?(slot) }
  return warn "apply-extras: palette lacks #{missing.join(', ')}, skipping OmniWM" unless missing.empty?

  patched, touched = patch_omniwm_lines(File.readlines(path), palette)
  return warn 'apply-extras: no OmniWM colour tables matched, settings.toml untouched' if touched.empty?

  atomic_write(path, patched.join)
  puts "apply-extras: OmniWM -> #{path} (#{touched.size} tables; accent=#{ACCENT})"
end

# --- workmux -----------------------------------------------------------------
def hex_plain(palette, slot)
  format('#%02x%02x%02x', *palette.fetch(slot))
end

def write_workmux(palette, scheme)
  path = File.join(config_home, 'workmux', 'config.yaml')
  return warn "apply-extras: #{path} not found, skipping workmux" unless File.file?(path)

  missing = WORKMUX_CUSTOM.values.uniq.reject { |slot| palette.key?(slot) }
  return warn "apply-extras: palette lacks #{missing.join(', ')}, skipping workmux" unless missing.empty?

  config = YAML.safe_load(File.read(path)) || {}
  existing = config['theme']
  base_scheme = existing.is_a?(Hash) ? existing['scheme'] : existing
  config['theme'] = {
    'scheme' => base_scheme || 'default',
    'custom' => (existing.is_a?(Hash) ? existing['custom'] || {} : {})
                .merge(WORKMUX_CUSTOM.transform_values { |slot| hex_plain(palette, slot) })
  }

  atomic_write(path, config.to_yaml)
  puts "apply-extras: workmux -> #{path} (scheme=#{scheme})"
end

# --- nushell -----------------------------------------------------------------
def hex(palette, slot)
  format('"#%02x%02x%02x"', *palette.fetch(slot))
end

def write_nushell(palette, scheme)
  path = File.join(config_home, 'nushell', 'autoload', 'tinty_colors.nu')
  return warn "apply-extras: #{File.dirname(path)} missing, skipping nushell" unless Dir.exist?(File.dirname(path))

  rows = NU_MAP.map do |key, (slot, attr)|
    value = attr ? "{ fg: #{hex(palette, slot)}, attr: \"#{attr}\" }" : hex(palette, slot)
    format('    %<key>-27s %<value>s', key: "#{key}:", value: value)
  end
  rows << format('    %-27s { fg: %s, bg: %s }', 'search_result:', hex(palette, 'base00'), hex(palette, 'base0A'))
  rows << format('    %-27s { attr: "u" }', 'shape_matching_brackets:')
  atomic_write(path, <<~NU)
    # Generated by tinty/hooks/apply-extras.rb - do not edit.
    # scheme: #{scheme}
    $env.config.color_config = {
    #{rows.join("\n")}
    }
  NU
  puts "apply-extras: nushell -> #{path}"
end

# --- run -------------------------------------------------------------------
scheme = current_scheme
palette = load_palette(*split_scheme(scheme))
write_sketchybar(palette, scheme)
write_omniwm(palette)
write_nushell(palette, scheme)
write_workmux(palette, scheme)
