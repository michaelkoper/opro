class Opro::Oauth::ClientApp < CouchRest::Model::Base

  property :name, String
  property :app_id, String
  property :app_secret, String
  property :permissions, String
  property :user_id, String
  property :permissions, Hash

  timestamps!

  belongs_to :user
  validates  :app_id, :uniqueness => true
  validates  :name,   :uniqueness => true

  alias_attribute :client_id, :app_id

  alias_attribute :client_secret, :app_secret
  alias_attribute :secret,        :app_secret

  design do
    view :by_user_id
    view :by_app_id
    view :by_app_id_and_secret
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
    find_by_app_id_and_secret([app_id, app_secret])
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

  # Copy paste from active support
  def alias_attribute(new_name, old_name)
    module_eval <<-STR, __FILE__, __LINE__ + 1
      def #{new_name}; self.#{old_name}; end          # def subject; self.title; end
      def #{new_name}?; self.#{old_name}?; end        # def subject?; self.title?; end
      def #{new_name}=(v); self.#{old_name} = v; end  # def subject=(v); self.title = v; end
    STR
  end
end