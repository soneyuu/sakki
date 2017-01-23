class EntryRepository
  include Enumerable

  def initialize(db)
    @db = db
  end

  def save(entry)
    columns = Entry::COLUMNS.reject { |key| key == :id }
    values = columns.map { |key| entry.instance_variable_get("@#{key}") }
    query = "INSERT INTO `entries` (#{columns.join(", ")}) VALUES (#{columns.map { '?' }.join(', ')})"
    stmt = @db.prepare(query)
    stmt.execute(*values)
    entry.id = @db.last_id
    return entry.id
  end

  def fetch(id)
    query = "SELECT * FROM `entries` WHERE `id` = ?"
    stmt = @db.prepare(query)
    res = stmt.execute(id)

    data = res.first
    entry = Entry.new(data)

    return entry
  end

  def each(&block)
    entries = []
    query = "SELECT * FROM `entries`"
    res = @db.query(query)

    res.each do |row|
      entry = Entry.new
      entry.title = row["title"]
      entry.body = row["body"]
      entries.push(entry)
    end

    entries.each(&block)
  end
end
