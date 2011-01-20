class Post < ActiveRecord::Base
  has_ancestry
  has_friendly_id :number
  has_many :translations

  # will_paginate
  cattr_reader :per_page
  @@per_page = 100

  def to_title
    "<h2>[ruby-dev:#{self.number}] #{self.subject}</h2>"
  end

  def translation
    if (trs = self.translations)
      trs.max_by{|tr| tr.created_at}
    end
  end

  def translation_subject
    translation.try(:subject) or self.subject
  end

  def translation_body
    translation.try(:body) or self.body
  end
end
