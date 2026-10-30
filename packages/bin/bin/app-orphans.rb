#!/usr/bin/env ruby

require "json"
require "open3"
require "pathname"
require "find"
require "set"

HOME = Pathname.new(Dir.home)

SCAN_DIRS = [
  HOME / "Library/Application Support",
  HOME / "Library/Caches",
  HOME / "Library/Containers",
  HOME / "Library/Group Containers",
  HOME / "Library/Preferences",
  HOME / "Library/Saved Application State",
  HOME / "Library/Logs",
  HOME / "Library/WebKit",
  HOME / "Library/HTTPStorages",
  HOME / "Library/LaunchAgents"
].freeze

# ------------------------------------------------------------
# Installed applications
# ------------------------------------------------------------

def installed_apps
  apps = []

  app_paths = []

  ["/Applications", "#{Dir.home}/Applications"].each do |dir|
    next unless Dir.exist?(dir)

    Dir.glob("#{dir}/**/*.app").each do |path|
      app_paths << path
    end
  end

  app_paths.uniq.each do |path|
    info = "#{path}/Contents/Info.plist"
    next unless File.file?(info)

    json, status = Open3.capture2(
      "plutil", "-convert", "json", "-o", "-", "--", info
    )

    next unless status.success?

    begin
      plist = JSON.parse(json)

      bundle_id = plist["CFBundleIdentifier"]
      name = plist["CFBundleDisplayName"] ||
             plist["CFBundleName"] ||
             plist["CFBundleExecutable"]

      next unless bundle_id && name

      apps << {
        name: name,
        bundle_id: bundle_id,
        path: path
      }
    rescue JSON::ParserError
      next
    end
  end

  apps
end

# ------------------------------------------------------------
# Bundle-ID extraction
# ------------------------------------------------------------

def bundle_ids(apps)
  apps.map { |a| a[:bundle_id].downcase }.to_set
end

# ------------------------------------------------------------
# Find artifacts whose names contain a bundle identifier
# ------------------------------------------------------------

def bundle_id_candidates(apps)
  candidates = []

  SCAN_DIRS.each do |root|
    next unless root.directory?

    root.children.each do |entry|
      name = entry.basename.to_s.downcase

      apps.each do |app|
        id = app[:bundle_id].downcase

        next unless name.include?(id)

        candidates << {
          path: entry.to_s,
          size: entry.directory? ? directory_size(entry) : entry.size,
          app: app,
          confidence: "HIGH",
          reason: "bundle identifier appears in filename"
        }
      end
    end
  end

  candidates
end

# ------------------------------------------------------------
# Directory size
# ------------------------------------------------------------

def directory_size(path)
  total = 0

  Find.find(path.to_s) do |file|
    begin
      total += File.size(file) if File.file?(file)
    rescue Errno::ENOENT, Errno::EACCES
      # Ignore files that disappear or aren't readable.
    end
  end

  total
end

# ------------------------------------------------------------
# Main
# ------------------------------------------------------------

require "find"
require "set"

puts "Collecting installed applications..."

apps = installed_apps

puts "Found #{apps.length} applications."
puts
puts "Scanning ~/Library..."
puts

candidates = bundle_id_candidates(apps)

if candidates.empty?
  puts "No obvious application leftovers found."
  exit
end

candidates.sort_by { |c| -c[:size] }.each_with_index do |candidate, index|
  puts "#{index + 1}. #{candidate[:app][:name]}"
  puts "   #{candidate[:path]}"
  puts "   #{candidate[:size] / 1024.0 / 1024.0.round(2)} MB"
  puts "   bundle: #{candidate[:app][:bundle_id]}"
  puts "   confidence: #{candidate[:confidence]}"
  puts "   reason: #{candidate[:reason]}"
  puts
end

total = candidates.sum { |c| c[:size] }

puts "Potential leftovers: #{candidates.length}"
puts "Total size: #{(total / 1024.0 / 1024.0).round(1)} MB"
puts
puts "READ-ONLY: nothing was deleted."
