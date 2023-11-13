require "glimmer-dsl-libui"
require "bcrypt"
require "openssl"
require "base64"
require "json"
require "io/console"

require "fileutils"
require "file_utils/adamantite_file_utils"
require "base/adamantite"
require "base/password_object"
require "gui/screen/login_screen"
require "gui/screen/copy_screen"
require "gui/screen/show_screen"
require "gui/screen/set_master_password_screen"
require "gui/screen/update_master_password_screen"
require "gui/request/login_request"
require "gui/request/add_password_request"
require "gui/request/update_master_password_request"
require "gui/request/set_master_password_request"
require "gui/form/password_object_form_window"

include Adamantite::AdamantiteFileUtils

module Adamantite
  class AdamantiteApp
    include Glimmer::LibUI::Application

    attr_accessor :add_password_request, :stored_passwords

    before_body do
      if !master_password_exists?
        set_master_password_request = GUI::Request::SetMasterPasswordRequest.new
        set_master_password_screen(set_master_password_request: set_master_password_request).show
      end

      login_request = GUI::Request::LoginRequest.new
      login_screen(login_request: login_request).show

      if !login_request.authenticated
        exit(0)
      end

      @adamantite = login_request.adamantite
      @stored_passwords = @adamantite.stored_passwords.map do |stored_password|
        [stored_password[:website_title], stored_password[:username], 'Edit', 'Copy', 'Show', 'Delete']
      end
      @master_password = @adamantite.master_password
      @master_password_salt = @adamantite.master_password_salt
      @add_password_request = GUI::Request::AddPasswordRequest.new(@master_password, @master_password_salt)
    end

    body {
      window('Adamantite', 800, 400) {
        margined true

        vertical_box {
          table {
            text_column('Title')
            text_column('Username')
            button_column('Edit') {
              on_clicked do |row|
                on_save = lambda do |password_object|
                  stored_password = []
                  stored_password << password_object.website_title
                  stored_password << password_object.username
                  stored_password << 'Edit'
                  stored_password << 'Copy'
                  stored_password << 'Show'
                  stored_password << 'Delete'
                  @stored_passwords[password_object.row_index] = stored_password
                  adamantite_stored_password = {
                    "dir_name": password_object.dir_name,
                    "website_title": password_object.website_title,
                    "username": @adamantite.retrieve_password_info(password_object.dir_name, "username")
                  }
                  @adamantite.stored_passwords[password_object.row_index] = adamantite_stored_password
                end
                website_title = @stored_passwords[row][0]
                username = @stored_passwords[row][1]
                dir_name = @adamantite.stored_passwords[row][:dir_name]
                password = @adamantite.retrieve_password_info(dir_name, "password")
                password_object = Base::PasswordObject.new(website_title, username, password, password, row, dir_name)
                password_object_form_window(adamantite: @adamantite, on_save: on_save, password_object: password_object).show
              end
            }
            button_column('Copy') {
              on_clicked do |row|
                IO.popen('pbcopy', 'w') do |f|
                  dir_name = @adamantite.stored_passwords[row][:dir_name]
                  f << @adamantite.retrieve_password_info(dir_name, "password")
                end
                copy_screen(password_title: @stored_passwords[row].first).show
              end
            }
            button_column('Show') {
              on_clicked do |row|
                dir_name = @adamantite.stored_passwords[row][:dir_name]
                show_screen(password: @adamantite.retrieve_password_info(dir_name, "password")).show
              end
            }
            button_column('Delete') {
              on_clicked do |row|
                @adamantite.delete_password(@adamantite.stored_passwords[row][:dir_name])
                @adamantite.stored_passwords.delete_at(row)
                @stored_passwords.delete_at(row)
              end
            }
            cell_rows <=> [self, :stored_passwords]
          }
          horizontal_box {
            button('Add Password') {
              on_clicked do
                on_save = lambda do |password_object|
                  stored_password = []
                  stored_password << password_object.website_title
                  stored_password << password_object.username
                  stored_password << 'Edit'
                  stored_password << 'Copy'
                  stored_password << 'Show'
                  stored_password << 'Delete'
                  @stored_passwords << stored_password
                  adamantite_stored_password = {
                    "dir_name": password_object.dir_name,
                    "website_title": password_object.website_title,
                    "username": @adamantite.retrieve_password_info(password_object.dir_name, "username")
                  }
                  @adamantite.stored_passwords << adamantite_stored_password
                end
                password_object_form_window(adamantite: @adamantite, on_save: on_save).show
              end
            }
            button('Update Master Password') {
              on_clicked do
                update_master_password_request = GUI::Request::UpdateMasterPasswordRequest.new(@adamantite)
                update_master_password_screen(update_master_password_request: update_master_password_request).show
              end
            }
          }
        }
      }
    }
  end
end