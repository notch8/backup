#------------------------------------------------------------------------------
# Backup Global Settings
# @author: Nate Murray <nate@natemurray.com>
#   @date: Mon Aug 28 07:28:22 PDT 2006
# 
# The settings contained in this file will be global for all tasks and can be
# overridden locally.
#------------------------------------------------------------------------------

# Sepcify sever settings
set :servers,           %w{ localhost }
set :action_order,      %w{ content compress encrypt deliver rotate cleanup }

# Name of the SSH user
set :ssh_user,          ENV['USER']

# Path to your SSH key
set :identity_key,      ENV['HOME'] + "/.ssh/id_rsa"

# Set global actions
action :compress, :method => :tar_bz2 
action :deliver,  :method => :mv    
#action :deliver,  :method => :scp    
action :rotate,   :method => :via_mv
#action :rotate,   :method => :via_ssh
#action :encrypt,  :method => :gpg

# Specify a directory that backup can use as a temporary directory
set :tmp_dir, "/tmp"

# These settings specify the rotation variables
# Rotation method. Currently the only method is gfs, grandfather-father-son. 
# Read more about that below
set :rotation_method,  :gfs

# :mon-sun
# :last_day_of_the_month # whatever son_promoted on son was, but the last of the month
# everything else you can define with a Runt object
# set :son_created_on,     :every_day - if you dont want a son created dont run the program
# a backup is created every time the program is run

set :son_promoted_on,    :fri
set :father_promoted_on, :last_fri_of_the_month

# more complex
# mon_wed_fri = Runt::DIWeek.new(Runt::Mon) | 
#               Runt::DIWeek.new(Runt::Wed) | 
#               Runt::DIWeek.new(Runt::Fri)
# set :son_promoted_on, mon_wed_fri

set :sons_to_keep,         14
set :fathers_to_keep,       6
set :grandfathers_to_keep,  6   # 6 months


# -------------------------
# Standard Actions
# -------------------------
action(:tar_bz2) do
  name = c[:tmp_dir] + "/" + File.basename(last_result) + ".tar.bz2"
  sh "tar -cvjf #{name} #{last_result}"
  name
end

action(:scp) do
  # what should the default scp task be?
  # scp the local file to the foreign directory. same name.
  # todo - specify a key
  c[:servers].each do |server|
    host = server =~ /localhost/ ? "" : "#{server}:"
    sh "scp #{last_result} #{host}#{c[:backup_path]}/"
  end
  c[:backup_path] + "/" + File.basename(last_result)  
end

action(:mv) do
  sh "mv #{last_result} #{c[:backup_path]}/"
  # backup_path + "/" + last_result
  c[:backup_path] + "/" + File.basename(last_result)
end


# TODO - make it so that the 'set' variables are available to these actions
# without having to access the config array.