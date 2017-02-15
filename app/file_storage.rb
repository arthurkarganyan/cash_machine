class FileStorage
  PATH = APP_ROOT + '/db/storage'

  def self.save(obj)
    dumped = Marshal.dump obj
    File.open(PATH, 'w') { |f| f.write(dumped) }
  end

  def self.load
    Marshal.load(File.read(PATH)) rescue nil
  end

  def self.clear
    File.delete(PATH) rescue nil
  end
end