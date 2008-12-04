class AsotSweeper < ActionController::Caching::Sweeper
  observe Asot

  def after_save(record)
    self.class::sweep
  end

  def after_create(record)
    self.class::sweep
  end
  
  def after_update(record)
    self.class::sweep
  end
  
  def after_destroy(record)
    self.class::sweep
  end

  def self.sweep
    cache_dir = ActionController::Base.page_cache_directory
    unless cache_dir == RAILS_ROOT+"/public"
      FileUtils.rm_r(Dir.glob(cache_dir+"/*")) rescue Errno::ENOENT
      RAILS_DEFAULT_LOGGER.info("Cache directory '#{cache_dir}' fully sweeped.")
    end
    # Delete index.html - always.
    FileUtils.rm_r(Dir.glob(cache_dir+"/index.html")) rescue Errno::ENOENT
    FileUtils.rm_r(Dir.glob(cache_dir+"/by-rank.html")) rescue Errno::ENOENT
  end
end

