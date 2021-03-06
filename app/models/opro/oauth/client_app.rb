class Opro::Oauth::ClientApp < CouchRest::Model::Base
  use_database :oauths

  property :name, String
  property :app_id, String
  property :app_secret, String
  property :user_id, String
  property :permissions, Hash, default: {}

  timestamps!

  belongs_to :user
  validates  :app_id, :uniqueness => true
  validates  :name,   :uniqueness => true

  # alias_attribute :client_id, :app_id
  # alias_attribute :client_secret, :app_secret
  # alias_attribute :secret,        :app_secret

  design do
    view :by_user_id
    view :by_app_id
    view :by_app_id_and_app_secret
    view :by_app_id_and_user_id

    view :by_id_and_user_id, :map => "
      function(doc) {
        if (doc['type'] == 'Opro::Oauth::ClientApp' && doc['user_id']) {
          emit([doc['_id'], doc['user_id']], 1);
        }
      }
    ", :reduce => :sum

  end

  # alias_attributes

  def self.find_by_client_id(client_id)
    find_by_app_id(client_id)
  end

  def self.authenticate(app_id, app_secret)
    find_by_app_id_and_app_secret([app_id, app_secret])
  end

  def self.create_with_user_and_name(user, name)
    client_app = self.create(
      user: user,
      name: name,
      app_id: generate_unique_app_id,
      app_secret: SecureRandom.hex(16)
    )
    client_app
  end

  def self.generate_unique_app_id(app_id = SecureRandom.hex(16))
    client_app = find_by_app_id(app_id)
    return app_id if client_app.blank?
    generate_unique_app_id
  end

  # alias_attributes
  def client_id; self.app_id; end
  def client_id=(v); self.app_id = v; end
  def client_secret; self.app_secret; end
  def client_secret=(v); self.app_secret = v; end
  def secret; self.app_secret; end
  def secret=(v); self.app_secret = v; end

end