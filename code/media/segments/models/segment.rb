class Segment < ActiveRecord::Base
  validates_presence_of :recording_id

  belongs_to :recording

  has_many :words

  include Timecodes

  acts_as_list :scope => :recording

  def next_segment_preview
    lower_item.words.collect(&:body).join(' ') if lower_item
  end

  def assign_words!
    recording.words.where("start_time >= ? AND start_time <= ?", start_time, end_time).each do |word|
      word.update_attribute(:segment_id, id)
    end
  end

  def create_words!
    raise "segment already has words" if words.exists?

    raw_words.each do |raw_word|
      words.create!(:body => raw_word, :recording => recording)
    end
  end

  def raw_words
    body.to_s.split(/ /)
  end

end
