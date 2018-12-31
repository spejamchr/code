#!/usr/bin/env ruby
#
# NAME
#     safe -- Password-protect files from the command line
#
# SYNOPSIS:
#     safe name [-o | -c] file
#     safe name [-e | -f | -d]
#     safe [name] -l
#
# DESCRIPTION
#
#     Open and close password-protected files. "Closed" files are removed from
#     the filesystem and placed in the ~/.safe directory. Opening a file
#     restores it to its original place in the fs, removing it from the ~/.safe
#     directory. Each usage will request a password.
#
#     Files are organized into safes, which are named and password-protected. If
#     you don't know the password, you don't know much: You can't see filenames,
#     or which files are in which safes. You can list the names of the safes.
#     Remember your password!
#
#     The following options are available
#
#     --close  -c     Close the given file
#     --open   -o     Open the given file
#     --list   -l     List all files in the safe (w/o a safe name, list safes)
#     --empty  -e     Open all files in the safe
#     --fill   -f     Close all files in the safe
#     --delete -d     Delete this safe as-is (will not open/close files first)
#
require 'digest'
require 'openssl'
require 'securerandom'
require 'yaml'
require 'base64'
require 'io/console'
require 'fileutils'

# Store password-protected files
#
class Safe

  SAFE_DIRECTORY = File.join(Dir.home, '.old_safe').freeze
  SALT_FILE = File.join(SAFE_DIRECTORY, 'salt').freeze
  BUFFER_BYTES = 512

  # Initialize a safe
  #
  # @param [String] password
  # @return [Safe]
  #
  def initialize(name, password)
    Dir.mkdir(SAFE_DIRECTORY) unless File.directory?(SAFE_DIRECTORY)

    @name = name
    @key = Digest::SHA2.digest("#{password}#{salt}")

    load_doc_list
  end

  # List all documents stored in this safe
  #
  def list
    @doc_list
  end

  # Secure a file in the safe
  #
  # @param [String] filename Relative or absolute path to file to secure
  #
  def close(filename)
    filename = File.expand_path(filename)
    secure_file = digest_filepath(filename)

    _close(filename, secure_file)

    load_doc_list
    @doc_list[filename] ||= {}
    @doc_list[filename]['last_closed'] = Time.now
    @doc_list[filename]['safe'] = true
    save_doc_list

    File.delete(filename)
  end

  # Extract a file from the safe
  #
  # @param [String] filename Relative or absolute path to file to extract
  #
  def open(filename)
    filename = File.expand_path(filename)
    secure_file = digest_filepath(filename)

    _open(filename, secure_file)

    load_doc_list
    @doc_list[filename] ||= {}
    @doc_list[filename]['last_opened'] = Time.now
    @doc_list[filename]['safe'] = false
    save_doc_list

    File.delete(secure_file)
  end

  # Open all files in the safe
  #
  def empty
    @doc_list.each do |f, d|
      next unless d['safe']
      open(f)
    end
  end

  # Close all files in the safe
  #
  def fill
    @doc_list.each do |f, d|
      next if d['safe']
      close(f)
    end
  end

  # Delete the safe as-is, without opening or closing files
  #
  # All closed files are lost. Open files are not lost.
  #
  def delete
    @doc_list.each do |f, d|
      next unless d['safe']
      secure_file = digest_filepath(f)
      File.delete(secure_file)
    end
    File.delete(digest_filepath)
  end

  private

  def new_cipher
    OpenSSL::Cipher.new('AES-256-CBC')
  end

  def save_doc_list
    File.open(digest_filepath, 'wb') do |w|
      cipher = new_cipher
      cipher.encrypt
      iv = cipher.random_iv
      cipher.key = @key
      cipher.iv  = iv

      w << iv
      w << cipher.update(@doc_list.to_yaml)
      w << cipher.final
    end
  end

  def load_doc_list
    return @doc_list = {} unless File.exist?(digest_filepath)

    w = ''
    decipher = new_cipher
    decipher.decrypt
    decipher.key = @key

    first_block = true
    File.open(digest_filepath, 'rb') do |r|
      until r.eof?
        if first_block
          decipher.iv = r.read(decipher.iv_len)
          first_block = false
        else
          w << decipher.update(r.read(BUFFER_BYTES))
        end
      end
    end

    w << decipher.final
    @doc_list = YAML.load(w)
  end

  def salt
    return @salt if defined?(@salt)

    unless File.exist?(SALT_FILE)
      File.open(SALT_FILE, 'wb') { |f| f << SecureRandom.hex(16) }
    end

    @salt = File.read(SALT_FILE)
  end

  # Called without args, this will be the path to the doc_list file
  def digest_filepath(other=nil)
    digest = other.nil? ?
      @name :
      Digest::SHA2.digest("#{@key}#{@name}#{other}")

    filename = Base64.urlsafe_encode64(digest, padding: false)
    File.join(SAFE_DIRECTORY, filename)
  end

  def _close(clear_file, secure_file)
    File.open(clear_file, 'rb') do |r|
      File.open(secure_file, 'wb') do |w|
        cipher = new_cipher
        cipher.encrypt
        iv = cipher.random_iv
        cipher.key = @key
        cipher.iv  = iv

        w << iv
        w << cipher.update(r.read(BUFFER_BYTES)) until r.eof?
        w << cipher.final
      end
    end
  end

  def _open(clear_file, secure_file)
    File.open(clear_file, 'wb') do |w|
      decipher = new_cipher
      decipher.decrypt
      decipher.key = @key

      first_block = true
      File.open(secure_file, 'rb') do |r|
        until r.eof?
          if first_block
            decipher.iv = r.read(decipher.iv_len)
            first_block = false
          else
            w << decipher.update(r.read(BUFFER_BYTES))
          end
        end
      end

      w << decipher.final
    end
  end

end

def testit
  password = SecureRandom.uuid
  name = SecureRandom.uuid
  Safe.new(name, password) # Make sure the .safe directory exists

  test_dir = File.join(Safe::SAFE_DIRECTORY, 'test')
  Dir.mkdir(test_dir)

  hitxt_path = File.join(test_dir, 'hi.txt')
  hitxt_string = "Hello World!\n"
  File.write(hitxt_path, hitxt_string)

  byetxt_path = File.join(test_dir, 'bye.txt')
  byetxt_string = "Goodbye now...\n"
  File.write(byetxt_path, byetxt_string)

  Safe.new(name, password).close(hitxt_path)
  puts 'Closed hi.txt'
  Safe.new(name, password).list
  puts 'Listed'
  Safe.new(name, password).close(byetxt_path)
  puts 'Closed bye.txt'
  Safe.new(name, password).list
  puts 'Listed again'
  Safe.new(name, password).empty
  puts 'Emptied'
  File.read(hitxt_path) == hitxt_string ?
    puts('hitxt is correct') : puts('hitxt is corrupted')
  File.read(byetxt_path) == byetxt_string ?
    puts('byetxt is correct') : puts('byetxt is corrupted')
  Safe.new(name, password).fill
  puts 'Filled'
  Safe.new(name, password).delete
  puts 'Deleted'

# ensure
  FileUtils.rm_rf(test_dir)
end

def doit(name, method, filepath)
  print "Password: "
  password = STDIN.noecho(&:gets).chomp
  puts

  safe = Safe.new(name, password)

  case method
  when :'--close',  :'-c' then safe.close(filepath)
  when :'--open',   :'-o' then safe.open(filepath)
  when :'--list',   :'-l' then puts safe.list
  when :'--empty',  :'-e' then safe.empty
  when :'--fill',   :'-f' then safe.fill
  when :'--delete', :'-d' then safe.delete
  end
end

if ARGV[0].to_sym == :'--test'
  testit
else
  name = ARGV[0]
  method = ARGV[1].to_sym
  filepath = ARGV[2]
  doit(name, method, filepath)
end
