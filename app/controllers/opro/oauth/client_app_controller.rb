class Opro::Oauth::ClientAppController < OproController
  before_filter :opro_authenticate_user!

  def new
    @client_app = Opro::Oauth::ClientApp.new
  end

  # Show all client applications belonging to the current user
  def index
    @client_apps = Opro::Oauth::ClientApp.by_user_id.key(current_user.id)
  end

  def show
    @client_app = client_app
  end

  def edit
    @client_app = client_app
  end

  def update
    @client_app = client_app
    @client_app.name = params[:opro_oauth_client_app][:name]
    if @client_app.save
      redirect_to oauth_client_app_path(@client_app)
    else
      render :edit
    end
  end

  def create
    @client_app = client_app
    @client_app ||= Opro::Oauth::ClientApp.create_with_user_and_name(current_user, params[:opro_oauth_client_app][:name])
    if @client_app.save
      redirect_to oauth_client_app_path(@client_app)
    else
      render :new
    end
  end

  def client_app
    Opro::Oauth::ClientApp.find_by_id_and_user_id([params[:id], current_user.id])
  end
end
