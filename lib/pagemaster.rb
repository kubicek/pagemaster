require 'jekyll'
require_relative 'collection'

include FileUtils

# Jekyll comand to generate markdown collection pages from CSV/YML/JSON records
class Pagemaster < Jekyll::Command
  class << self

    def init_with_program(prog)
      prog.command(:pagemaster) do |c|
        c.syntax 'pagemaster [options] [args]'
        c.description 'Generate md pages from collection data.'
        c.option :no_perma, '--no-permalink', 'Skips adding hard-coded permalink.'
        c.option :force, '--force', 'Erases pre-existing collection before regenerating.'
        c.action { |args, options| execute(args, options) }
      end
    end

    def execute(args, opts = {}, config = nil)
      site = config || self.site_config
      raise StandardError, 'No collections in config' if site[:collections].nil?

      args.map do |name|
        collection = Collection.new(site, name)
        generate_pages(site, collection, opts)
      end
    end

    def site_config
      config = config || YAML.load_file('_config.yml')
      {
        source: config.fetch('source', nil),
        collections: config.fetch('collections', nil),
        collections_dir: config.fetch('collections_dir', nil),
        permalink: config.fetch('permalink', nil)
      }
    rescue => e
      raise StandardError, 'Cannot load _config.yml'
    end

    def generate_pages(site, collection, opts)
      perma   = !opts.fetch(:no_perma, nil)
      force   = !!opts.fetch(:force, false)

      mkdir_p(collection.page_dir)

      collection.data.each do |d|
        pagename       = slug(d.fetch(collection.id_key))
        pagepath       = "#{collection.page_dir}/#{pagename}.md"
        d['layout']    = collection.layout
        d['permalink'] = permalink(collection, pagename, site) if perma
        if !File.exist?(pagepath) or force
          File.open(pagepath, 'w') { |f| f.write("#{d.to_yaml}---") }
        else
          puts "#{pagename}.md already exits. Skipping."
        end
      end
    end

    def permalink(collection, pagename, site)
      "/#{collection.name}/#{pagename}#{permalink_ext(site)}"
    end

    def permalink_ext(site)
      site[:permalink] == 'pretty' ? '/' : '.html'
    end

    def remove_diacritics(str)
      to_replace  = 'ÀÁÂÃÄÅàáâãäåĀāĂăĄąÇçĆćĈĉĊċČčÐðĎďĐđÈÉÊËèéêëĒēĔĕĖėĘęĚěĜĝĞğĠġĢģĤĥĦħÌÍÎÏìíîïĨĩĪīĬĭĮįİıĴĵĶķĸĹĺĻļĽľĿŀŁłÑñŃńŅņŇňŉŊŋÒÓÔÕÖØòóôõöøŌōŎŏŐőŔŕŖŗŘřŚśŜŝŞşŠšſŢţŤťŦŧÙÚÛÜùúûüŨũŪūŬŭŮůŰűŲųŴŵÝýÿŶŷŸŹźŻżŽž'
      replaced_by = 'AAAAAAaaaaaaAaAaAaCcCcCcCcCcDdDdDdEEEEeeeeEeEeEeEeEeGgGgGgGgHhHhIIIIiiiiIiIiIiIiIiJjKkkLlLlLlLlLlNnNnNnNnnNnOOOOOOooooooOoOoOoRrRrRrSsSsSsSssTtTtTtUUUUuuuuUuUuUuUuUuUuWwYyyYyYZzZzZz'
      str.to_s.tr(to_replace, replaced_by)
    end

    def slug(str)
      normalized_string = remove_diacritics(str)
      normalized_string.downcase.tr(' ', '_').gsub(/[^:\w-]/, '')
    end
  end
end
