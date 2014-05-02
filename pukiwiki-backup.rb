#coding: utf-8
require 'net/sftp'
require 'yaml'

class SFTP
  def initialize
    @config = YAML.load_file("config.yaml")  
    @sftp = Net::SFTP.start(@config['sftp']['address'], @config['sftp']['user'], :password => @config['sftp']['pass'])
  end

  def showConfig
    puts @config
  end

  def ls(address = @config["default"]["remote"])
    dir = []
    @sftp.dir.foreach(address) do |entry|
      dir.push entry
    end
    return dir
  end

  def mkdir(dir = [])
    dir = [dir] if dir.kind_of?(String)
    dir.each do |item|
      Dir.mkdir(item, 0777) unless File.exist?(item)
    end
  end

  def download(dir = "wiki")
    self.mkdir @config["default"]["local"] + "/" + dir
    address = @config["default"]["remote"] + "/" + dir
    @sftp.dir.foreach(address) do |item|
      unless item.directory?
        remote = address + "/" + item.name
        local = @config["default"]["local"] + "/" + dir + "/" + item.name

        file = @sftp.download!(remote)
        local_file = File.open(local, "w+")
        local_file.print file
        local_file.close
      end
    end
  end

  def backup
    self.mkdir @config["default"]["local"]
    @config["directory"].each do |item|
      puts "Download: #{item}"
      self.download item
    end 
  end
end

sftp = SFTP.new
# sftp.showConfig
# puts sftp.ls
sftp.backup
