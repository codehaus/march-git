namespace :db do
  namespace :sessions do
    desc "Expires old sessions"
    task :expire => :environment do
      Session.delete_all( [ 'updated_at < ?', Time.now - 86400 ] )
    end
  end
end

