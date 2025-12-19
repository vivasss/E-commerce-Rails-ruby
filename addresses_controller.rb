class AddressesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_address, only: [:edit, :update, :destroy, :set_default]
  
  def index
    @addresses = current_user.addresses.order(default: :desc, created_at: :desc)
  end
  
  def new
    @address = current_user.addresses.build
  end
  
  def create
    @address = current_user.addresses.build(address_params)
    
    if @address.save
      redirect_to addresses_path, notice: "Endereco adicionado"
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def edit
  end
  
  def update
    if @address.update(address_params)
      redirect_to addresses_path, notice: "Endereco atualizado"
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    @address.destroy
    redirect_to addresses_path, notice: "Endereco removido"
  end
  
  def set_default
    @address.update(default: true)
    redirect_to addresses_path, notice: "Endereco definido como padrao"
  end
  
  private
  
  def set_address
    @address = current_user.addresses.find(params[:id])
  end
  
  def address_params
    params.require(:address).permit(
      :address_type, :name, :street, :number, :complement,
      :neighborhood, :city, :state, :postal_code, :country, :phone, :default
    )
  end
end
