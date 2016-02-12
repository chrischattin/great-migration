require 'fog'

class GreatMigration

  attr_reader :rackspace, :aws, :rackspace_directory, :aws_directory, :files, :total

  def initialize(options={})
    @rackspace = Fog::Storage.new({
      :provider           => 'Rackspace',
      :rackspace_username => options[:rackspace_user],
      :rackspace_api_key  => options[:rackspace_key],
      :rackspace_region   => options[:rackspace_region]
    })
    @aws = Fog::Storage.new({
      :provider => 'aws',
      :aws_access_key_id => options[:aws_key],
      :aws_secret_access_key => options[:aws_secret],
      :region => 'us-west-2'
    })
    @rackspace_directory = rackspace.directories.get(options[:rackspace_container])
    @aws_directory = aws.directories.get(options[:aws_bucket])
    @files = []
    @total = 0
  end

  def copy_files(files)
    files.each do |f|
      file = self.rackspace_directory.files.get "#{f}"
      puts "Loading file: #{f}..."
      copy_file(file)
    end
  end

  private def copy_file(file)
    if file.content_type == 'application/directory'
      # skip directories
    else
      aws_directory.files.create(
        :key          => file.key,
        :body         => file.body,
        :content_type => file.content_type,
        :public       => true)
      puts "#{file} saved."
    end
  end

end
