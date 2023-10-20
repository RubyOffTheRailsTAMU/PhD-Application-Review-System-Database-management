class Applicant < ApplicationRecord
  has_one :toefl
  has_one :gre
  has_one :application_ielt
  has_many :schools
end
