describe Pagemaster do
  include_context 'shared'

  describe '.execute' do
    context 'with defaults / no options' do
      it 'runs without errors' do
        expect { Pagemaster.execute(args) }.not_to raise_error
      end

      it 'makes the correct dirs' do
        dirs.each { |dir| expect(exist(dir)) }
      end

      it 'generates md pages' do
        dirs.each { |dir| expect(Dir.glob("#{dir}/*.md")) }
      end
    end

    context 'with --no-permalink and --force' do
      it 'runs without errors' do
        opts = { no_perma: true, force: true }
        expect { Pagemaster.execute(args, opts) }.not_to raise_error
      end

      it 'makes the correct dirs' do
        dirs.each { |dir| expect(exist(dir)) }
      end

      it 'regenerates md pages (does not skip)' do
        dirs.each { |dir| expect(Dir.glob("#{dir}/*.md")) }
      end

      it 'skips writing permalinks' do
        Dir.glob("#{dirs.first}/*.md").each do |p|
          page = YAML.load_file(p)
          expect(page).not_to have_key('permalink')
        end
      end
    end

    context 'with a site source directory spefified' do
      let(:s_dirs) { dirs.map { |d| "#{site_with_source_dir[:source]}/#{d}" } }

      it 'runs without errors' do
        expect { Pagemaster.execute(args, { force: true }, site_with_source_dir ) }.not_to raise_error
      end

      it 'makes the correct dirs (within `source`)' do
        s_dirs.each { |dir| expect(exist(dir)) }
      end

      it 'generates md pages' do
        s_dirs.each { |dir| expect(Dir.glob("#{dir}/*.md")) }
      end
    end

    context 'with a site collections_dir specified' do
      let(:c_dirs) { dirs.map { |d| "#{site_with_collections_dir[:collections_dir]}/#{d}" } }

      it 'runs without errors' do
        expect { Pagemaster.execute(args, { no_perma: true }, site_with_collections_dir ) }.not_to raise_error
      end

      it 'makes the correct dirs (within `source`)' do
        c_dirs.each { |dir| expect(exist(dir)) }
      end

      it 'generates md pages' do
        c_dirs.each { |dir| expect(Dir.glob("#{dir}/*.md")) }
      end
    end
  end
end
