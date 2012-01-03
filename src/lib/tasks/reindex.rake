task :reindex=>["environment", "clear_search_indices"]  do
  User.current = User.first #set a user for orchestration

  ignore_list = ["CpConsumerUser", "TaskStatus"]

  Dir.glob(RAILS_ROOT + '/app/models/*.rb').each { |file| require file }
  models = ActiveRecord::Base.subclasses.sort{|a,b| a.name <=> b.name}
  models.each{|mod|
    if !ignore_list.include?(mod.name) && mod.respond_to?(:index)
       print "Re-indexing #{mod}\n"
       mod.index.import(mod.all)
    end
  }

  print "Re-indexing Repositories\n"
  Repository.all.each{|repo|
    repo.index_packages
    repo.index_errata
  }

end
