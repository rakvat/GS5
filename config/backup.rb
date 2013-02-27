# encoding: utf-8

require 'inifile'
SYSTEM_ODBC_CONFIGURATION = IniFile.load('/var/lib/freeswitch/.odbc.ini')

Backup::Model.new(:GS5, 'GS5 backup') do
 
  ##
  # Split [Splitter]
  #
  # Split the backup file in to chunks of 2 GB
  # if the backup file size exceeds 2 GB
  #
  # split_into_chunks_of 2048

  ##
  # MySQL [Database]
  #
  database MySQL do |db|
    # To dump all databases, set `db.name = :all` (or leave blank)
    db.name               = SYSTEM_ODBC_CONFIGURATION['gemeinschaft']['DATABASE']
    db.username           = SYSTEM_ODBC_CONFIGURATION['gemeinschaft']['USER']
    db.password           = SYSTEM_ODBC_CONFIGURATION['gemeinschaft']['PASSWORD']
    db.host               = "localhost"
    db.port               = 3306
    db.socket             = "/var/run/mysqld/mysqld.sock"
    db.skip_tables        = ["backup_jobs", "restore_jobs", "fax_thumbnails"]
  end

  ##
  # Faxes
  #
  if File.exists?('/var/opt/gemeinschaft/fax')
    archive :faxes do |archive|
      # Incoming faxes
      #
      Dir.glob("/var/opt/gemeinschaft/fax/in/**/*.pdf").each do |fax_file|
        archive.add(fax_file)
      end
      Dir.glob("/var/opt/gemeinschaft/fax/in/**/*.tiff").each do |fax_file|
        archive.add(fax_file)
      end

      # Outgoing faxes
      #
      Dir.glob("/var/opt/gemeinschaft/fax/out/**/*.pdf").each do |fax_file|
        archive.add(fax_file)
      end
      Dir.glob("/var/opt/gemeinschaft/fax/out/**/*.tiff").each do |fax_file|
        archive.add(fax_file)
      end
    end
  end

  ##
  # Voicemails
  #
  if File.exists?('/var/opt/gemeinschaft/freeswitch/voicemail')
    archive :voicemails do |archive|
      archive.add     '/var/opt/gemeinschaft/freeswitch/voicemail'
    end
  end

  ##
  # Avatars
  #
  if File.exists?('/opt/gemeinschaft/public/uploads/user/image')
    archive :avatars do |archive|
      archive.add     '/opt/gemeinschaft/public/uploads/user/image'
    end  
  end

  ##
  # Local (Copy) [Storage]
  #
  store_with Local do |local|
    local.path       = "/var/backups/"
  end

  ##
  # Gzip [Compressor]
  #
  compress_with Gzip
end