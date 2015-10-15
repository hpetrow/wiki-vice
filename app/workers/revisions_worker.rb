class RevisionsWorker
  require "pusher"
  include Sidekiq::Worker

  def perform(id)
    page = Page.find(id)
    wiki = WikiWrapper.new
    binding.pry
    revisions = wiki.get_page(page.title)
    columns = [:revid, :timestamp, :vandalism, :page_id, :author_id]
    values = []
    revisions.each do |r|
      if major_edit?(r) && user_exists?(r)
        vandalism = vandalism?(r)
        author_name = r["user"]
        anonymous = ip_address?(author_name)
        author = Author.find_or_create_by(name: author_name, anonymous: anonymous)
        values << [r['revid'], r["timestamp"], vandalism, page.id, author.id]
      end

    end
    Revision.import(columns, values)
    add_vandalism(id, page.title)

    pusher = Pusher::Client.new(
    { 
      app_id: ENV["PUSHER_APP_ID"],
      key: ENV["PUSHER_KEY"],
      secret: ENV["PUSHER_SECRET"]
    }
    ) 
    pusher.trigger("page_results_#{page.id}", "get_page", {:id => page.id, :title => page.title, :revisionRate => page.time_between_revisions})
  end

  def add_vandalism(page_id, title)
    wiki = WikiWrapper.new
    revisions = wiki.vandalism_revisions(title)
    if revisions
      revision = revisions.first
      content = revision["diff"]["*"]
      author = Author.find_or_create_by(name: revision["user"], anonymous: ip_address?(revision["user"]))
      Revision.create(revid: revision["revid"], page_id: page_id, author_id: author.id, timestamp: revision["timestamp"], content: content) 
    end   
  end

  def vandalism?(revision)
    revision["tags"].include?("possible libel or vandalism")
  end  

  def major_edit?(revision)
    !(revision["minor"]) && !(revision["bot"]) 
  end

  def user_exists?(revision)
    revision["user"]
  end

  def ip_address?(name)
    !!(/\w{3,4}:\w{3,4}:\w{3,4}:\w{3,4}:\w{3,4}:\w{3,4}:\w{3,4}:\w{3,4}|\d{2,3}\.\d{2,3}\.\d{2,3}\.\d{1,3}/.match(name)) 
  end

end