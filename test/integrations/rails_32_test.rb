require 'test_helper'
class Rails32Test < Test::Unit::TestCase
  include CompassRails::Test::RailsHelpers
  RAILS_VERSION = RAILS_3_2

  def test_rails_app_created
    within_rails_app('test_railtie', RAILS_VERSION) do |project|
      assert project.boots?
    end
  end


  def test_installs_compass
    within_rails_app('test_railtie', RAILS_VERSION) do |project|
      project.run_compass('init')
      assert project.has_config?
      assert project.has_screen_file?
      assert project.has_compass_import?
    end
  end

  def test_compass_compile
    within_rails_app('test_railtie', RAILS_VERSION) do |project|
      project.run_compass('init')
      project.run_compass('compile')
      assert project.directory.join('public/assets/screen.css').exist?
    end
  end

  def test_install_blueprint
    within_rails_app('test_railtie', RAILS_VERSION) do |project|
      project.run_compass('init')
      project.run_compass('install blueprint --force')
      assert project.directory.join('app/assets/stylesheets/partials').directory?
    end
  end

  def test_compass_preferred_syntax
    within_rails_app('test_railtie', RAILS_VERSION) do |project|
      project.set_rails('sass.preferred_syntax', :sass)
      project.run_compass('init')
      assert project.directory.join('app/assets/stylesheets/screen.css.sass').exist?
    end
  end

  def test_generated_images_directory
    sprites = File.expand_path("./test/fixtures/sprite_files/letter")
    within_rails_app('test_railtie', RAILS_VERSION) do |project|
      project.set_rails('compass.generated_images_dir', 'app/assets/images/generated')
      puts File.read("config/application.rb")
      FileUtils.cp_r sprites, project.directory.join("app/assets/images")
      open('app/assets/stylesheets/application.css.scss', "w") do |f|
        f.puts <<-SCSS
          @import "letter/*.png";
          @include all-letter-sprites;
        SCSS
      end
      FileUtils.rm "app/assets/stylesheets/application.css"
      FileUtils.rm "app/assets/javascripts/application.js" # was causing strange errors about jquery
      project.rake "assets:precompile"
      assert File.exists?('public/assets/application.css')
      assert Dir.glob("public/assets/generated/letter-s#{'[0-9a-f]'*10}.png").size == 1
      assert Dir.glob("public/assets/generated/letter-s#{'[0-9a-f]'*10}-*.png").size == 1
    end
  end

end
