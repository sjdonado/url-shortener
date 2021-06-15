# frozen_string_literal: true

class Link < ApplicationRecord
  validates :url, presence: true
  validates :slug, uniqueness: true

  validates :url,
            format: { with: /\A#{URI::DEFAULT_PARSER.make_regexp(%w[http https])}\z/, message: 'invalid format' }
  validates :url, length: { within: 3..30_000, on: :create, message: 'max length is 30000' }

  before_validation :generate_slug

  def generate_slug(attempts = 0)
    return if slug.present? || attempts == 3

    # Number of combinations 62P6
    generated_slug = SecureRandom.alphanumeric(6)

    if Link.exists?(slug: generated_slug)
      generate_slug(attempts + 1)
    else
      self.slug = generated_slug
    end
  end

  belongs_to :user, optional: true
end
