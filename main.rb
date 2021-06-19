require 'rubygems'
require 'bundler/setup'
require "google/cloud/storage"
require "stringio"

class Client
  def initialize
    storage = Google::Cloud::Storage.new(
      project_id: 'gcs-test',
      credentials: ENV['GOOGLE_APPLICATION_CREDENTIALS']
    )

    @bucket = storage.bucket "froyomuffin-test-bucket"
  end

  def write
    puts "Write"
    content = {
      name: "Potato",
      address: "15 Potato",
    }

    filename = 'test_file.json'

    file = @bucket.create_file(
      StringIO.new(content.to_json),
      filename
    )
  end

  def read
    puts "Read"
    filename = 'test_file.json'

    file = @bucket.file(filename)

    puts file.download.string
  end
end

puts "Starting"
client = Client.new
#client.write
client.read
