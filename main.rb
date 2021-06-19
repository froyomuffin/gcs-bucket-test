require 'rubygems'
require 'bundler/setup'
require "google/cloud/storage"
require "stringio"
require "json"

class Client
  def initialize
    storage = Google::Cloud::Storage.new(
      project_id: 'gcs-test',
      credentials: ENV['GOOGLE_APPLICATION_CREDENTIALS']
    )

    @bucket = storage.bucket "froyomuffin-test-bucket"
  end

  def write(content, filename)
    puts "Writing #{filename}"

    @bucket.create_file(
      StringIO.new(content.to_json),
      filename
    )
  end

  def read(filename)
    puts "Reading #{filename}"

    file = @bucket.file(filename)
    content = file.download

    puts content.string
    puts file.signed_url

    content
  end

  def create_test_file
    prefix = timestamp
    content = 10000.times.map do |iteration|
      { value: "#{prefix}-#{iteration}" }
    end

    filename = "#{temp_prefix}/#{timestamp}.json"

    write(content, filename)
  end

  def create_test_final_file
    result = @bucket.files(prefix: temp_prefix).flat_map do |file|
      content = file.download
      JSON.parse(content.string)
    end

    filename = "#{final_prefix}/#{timestamp}.json"

    puts result.to_json

    write(result.to_json, filename)
  end

  def reset_bucket
    puts "Reset"

    @bucket.files.each(&:delete)
  end

  def timestamp
    Time.now.to_i
  end

  def temp_prefix
    "temp"
  end

  def final_prefix
    "final"
  end
end

puts "Starting"
client = Client.new

# Create 10 files each with 10000 records
10.times do
  client.create_test_file
end

# Stitch them
result = client.create_test_final_file

# Get a signed URL
puts result.signed_url
