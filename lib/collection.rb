require 'csv'
require 'yaml'
require 'json'

class Collection
  attr_reader :name

  def initialize(site, name)
    @site   = site
    @name   = name
    @config = site[:collections].fetch(@name, nil)

    raise "Cannot find collection #{@name} in _config.yml" if @config.nil?
  end

  def id_key
    @config.fetch('id_key', nil)
  end

  def data
    validate(ingest_source_file)
  end

  def layout
    layout = @config.fetch('layout', nil)
    raise "No layout was specified for #{@name} in _config.yml" if layout.nil?
    layout
  end

  def ingest_source_file
    raise StandardError, "Collection #{@name} has no source specified" unless @config.key?('source')

    source = File.join([@site[:source], '_data', @config['source']].compact)

    raise "Cannot find #{source}" unless File.exist?(source)

    case File.extname(source)
    when '.csv'
      CSV.read(source, headers: true).map(&:to_hash)
    when '.json'
      JSON.parse(File.read(source).encode('UTF-8'))
    when /\.ya?ml/
      YAML.load_file(source)
    else
      raise "Can't load #{File.extname(source)} files. Culprit: #{source}"
    end
  end


  def validate(data)
    id_key = self.id_key

    raise "No id _key specified for collection #{@name}"if id_key.nil?

    ids = data.map { |d| d.fetch(id_key, nil) }
    is_nil = ids.select { |i| i.nil? }
    not_unique = ids.select { |i| ids.count(i) > 1 }.uniq! || []

    raise "#{@name} is missing values for required value '#{id_key}'" unless is_nil.empty?
    raise "#{@name} has the following nonunique '#{id_key}' ids: \n#{not_unique}" unless not_unique.empty?

    data
  end

  def page_dir
    File.join([@site[:source], @site[:collections_dir], "_#{@name}"].compact)
  end
end
