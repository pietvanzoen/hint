require "yaml"
require "time"
require "fileutils"

# Handles fetching, creating, and editing of notes.
# @param filepath [String] Path to notes yaml file.
class NotesRepo
  def initialize(filepath)
    @filepath = filepath
    File.write(@filepath, "") unless File.exist?(@filepath)
    @notes = fetch_notes
  end

  def find_all(params = {})
    notes = @notes.reject(&:archived_at)
    notes = notes.select { |note| note.book == params["book"] } if params["book"]
    notes.sort_by(&:created_at)
  end

  def find(params)
    notes = params["book"] ? find_all("book" => params["book"]) : find_all
    notes = notes.select { |n| n.id == params["id"].to_i } if params["id"]
    notes.first
  end

  def create!(params)
    params["id"] = last_id + 1
    new_note = Note.new(params)
    @notes.push(new_note)
    save!
    new_note
  end

  def update!(id, params = {})
    note = find("id" => id)
    note.update!(params)
    save!
    note
  end

  def archive!(params)
    note = find(params)
    note.archive!
    save!
  end

  def save!
    FileUtils.cp(@filepath, "#{@filepath}~") if File.exist? @filepath
    hashed_notes = @notes.map(&:to_hash)

    File.write(@filepath, hashed_notes.to_yaml)
    @notes = fetch_notes
  end

  def last_id
    note = @notes.sort_by(&:id).reverse.first
    return note.id unless note.nil?
  end

  def fetch_notes
    notes = YAML.load_file(@filepath) || []
    notes.map { |n| Note.new(n) }
  end

  private :save!, :fetch_notes, :last_id
end

# Note model
# @param id [String]
# @param book [String]
# @param content [String]
# @param created_at [Time]
# @param updated_at [Time]
# @param archived_at [Time]
class Note
  attr_reader :id, :book, :created_at, :updated_at, :archived_at, :content

  def initialize(params = {})
    @id = params.fetch("id").to_i
    @book = params.fetch("book")
    @content = params.fetch("content", "")
    @created_at = Time.parse(params.fetch("created_at", Time.now.to_s))
    @updated_at = Time.parse(params.fetch("updated_at", Time.now.to_s))
    @archived_at = nil
    @archived_at = Time.parse(params["archived_at"]) unless params.fetch("archived_at", "").empty?
  end

  def update!(params)
    @content = params["content"] if params["content"]
    @book = params["book"] if params["book"]
    @updated_at = Time.now
  end

  def archive!
    @archived_at = Time.now
    @updated_at = Time.now
  end

  def to_hash
    h = {}
    instance_variables.each do |var|
      h[var.to_s.delete("@")] = instance_variable_get(var).to_s
    end
    h
  end
end
