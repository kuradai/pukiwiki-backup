#coding: utf-8
require 'rubygems'
require 'net/sftp'
require 'git'
require 'yaml'

class SFTP
  def initialize
    begin
      config = YAML.load_file("config.yaml")
      puts "Load config file"
      @remote    = config["default"]["remote"]
      @local     = config["default"]["local"]
      @directory = config["directory"]
    rescue => e
      puts "Can't load config file"
      puts e
      return false
    end

    begin
      @sftp =
        Net::SFTP.start(
          config['sftp']['address'],
          config['sftp']['user'],
          :password => config['sftp']['pass']
        )
      puts "Conection Success"
    rescue => e
      puts "Conection Error"
      puts e
      return false
    end
  end

  def ls(address = @remote)
    dir = []
    @sftp.dir.foreach(address) do |entry|
      dir.push entry
    end
    return dir
  end

  def mkdir(dir = [])
    dir = [dir] if dir.kind_of?(String)
    dir.each do |item|
      unless File.exist?(item)
        Dir.mkdir(item, 0777) 
        puts "mkdir: #{item}"
      end
    end
  end

  def download(dir = "wiki")
    items = 0
    self.mkdir @local + "/" + dir
    address = @remote + "/" + dir
    @sftp.dir.foreach(address) do |item|
      unless item.directory?
        items += 1
        remote = address + "/" + item.name
        local = @local + "/" + dir + "/" + item.name
        print("files: #{items}\r")
        File.open(local, "w+") do |f|
          f.print @sftp.download!(remote)
        end
      end
    end
    puts ""
  end

  def backup
    self.mkdir @local
    puts "Backup start"
    @directory.each do |item|
      puts "Download: #{item}"
      self.download item
    end
    puts "Backup complete"
  end
end


sftp = SFTP.new
sftp.backup
# sftp.showConfig
# puts sftp.ls
# sftp.backup

git = Git.open("../kuradai/pukiwiki-backup/")
git.config('user.name', 'Kuradai AdminBot')
git.config('user.email', 'admin@kuradai.org')
git.add(:all=>true) 
git.commit("Auto Backup" + " " + Time.now.strftime("%y-%m-%d"))
git.push()
