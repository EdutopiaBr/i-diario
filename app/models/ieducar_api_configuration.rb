class IeducarApiConfiguration < ActiveRecord::Base
  acts_as_copy_target

  audited

  include Audit

  has_many :synchronizations, class_name: "IeducarApiSynchronization"

  validates :url, :token, :secret_token, :unity_code, presence: true
  validates :url, format: { with: /^(http|https):\/\/[a-z0-9.:]+$/, multiline: true, message: "formato de url inválido" }, allow_blank: true

  def self.current
    self.first.presence || new
  end

  def start_synchronization(user = nil, entity_id = nil)
    transaction do
      synchronization = IeducarApiSynchronization.started.first

      return synchronization if synchronization

      synchronization = synchronizations.create!(status: ApiSynchronizationStatus::STARTED, author: user)

      job_id = IeducarSynchronizerWorker.perform_in(5.seconds, entity_id, synchronization.id)

      synchronization.set_job_id!(job_id)

      worker_batch = WorkerBatch.find_or_create_by!(
        main_job_class: IeducarSynchronizerWorker.to_s,
        main_job_id: synchronization.job_id
      )
      worker_batch.start!

      Rails.logger.info(key: 'IeducarApiConfiguration#start_synchronization',
                        from: "#{binding.of_caller(7).eval('self.class')}##{binding.of_caller(7).eval('__method__')}",
                        sync_id: synchronization.id,
                        entity_id: entity_id)

      synchronization
    end
  end

  def synchronization_in_progress?
    synchronizations.started.select(:running?).any?
  end

  def authenticate!(token)
    self.token == token
  end

  def to_api
    {
      url: url,
      access_key: token,
      secret_key: secret_token,
      unity_id: unity_code
    }
  end
end
