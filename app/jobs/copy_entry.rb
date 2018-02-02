class CopyEntry
  include BatchJobs
  include Sidekiq::Worker
  sidekiq_options queue: :worker_slow

  def perform(batch)
    ids = build_ids(batch)
    columns = NewEntry.column_names.map(&:to_sym)
    values = Entry.where(id: ids).where.not(feed_id: nil, public_id: nil, published: nil).pluck(*columns)
    NewEntry.import columns, values, validate: false
  end

  def schedule
    BatchScheduler.new().perform("Entry", "CopyEntry")
  end

end
