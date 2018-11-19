QUIET = !ENV['DEBUG']

require 'simplecov'
SimpleCov.start do
  add_filter 'spec'
end

require 'pagemaster'

shared_context 'shared', :shared_context => :metadata do
  before(:all){ Spec.reset }
  let(:site) { Pagemaster.site_config }
  let(:args) { site[:collections].map { |c| c[0] } }
  let(:dirs) { args.map { |a| "_#{a}"} }
  let(:site_with_source_dir) do
    config = site.clone
    config[:source] = 'src'
    config
  end
  let(:site_with_collections_dir) do
    config = site.clone
    config[:collections_dir] = 'collections'
    config
  end
end

require_relative 'setup'
require_relative 'pagemaster_spec'
