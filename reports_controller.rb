module Admin
  class ReportsController < BaseController
    def sales
      @start_date = parse_date(params[:start_date]) || 30.days.ago.to_date
      @end_date = parse_date(params[:end_date]) || Date.current
      
      service = Reports::SalesReportService.call(
        start_date: @start_date,
        end_date: @end_date,
        group_by: params[:group_by]&.to_sym || :day
      )
      
      @report = service.result
    end
    
    def inventory
      service = Reports::InventoryReportService.call(
        category_id: params[:category_id],
        low_stock_threshold: (params[:threshold] || 10).to_i
      )
      
      @report = service.result
    end
    
    def customers
      @start_date = parse_date(params[:start_date])
      @end_date = parse_date(params[:end_date])
      
      service = Reports::CustomerReportService.call(
        start_date: @start_date,
        end_date: @end_date
      )
      
      @report = service.result
    end
    
    def export_sales
      @start_date = parse_date(params[:start_date]) || 30.days.ago.to_date
      @end_date = parse_date(params[:end_date]) || Date.current
      
      service = Reports::SalesReportService.call(
        start_date: @start_date,
        end_date: @end_date
      )
      
      respond_to do |format|
        format.csv { send_data generate_sales_csv(service.result), filename: "vendas_#{@start_date}_#{@end_date}.csv" }
      end
    end
    
    def export_inventory
      service = Reports::InventoryReportService.call
      
      respond_to do |format|
        format.csv { send_data generate_inventory_csv(service.result), filename: "estoque_#{Date.current}.csv" }
      end
    end
    
    private
    
    def parse_date(date_string)
      return nil if date_string.blank?
      Date.parse(date_string)
    rescue Date::Error
      nil
    end
    
    def generate_sales_csv(report)
      require "csv"
      
      CSV.generate(headers: true) do |csv|
        csv << ["Periodo", "Pedidos", "Receita"]
        
        report[:by_period].each do |row|
          csv << [row[:period], row[:orders], row[:revenue]]
        end
      end
    end
    
    def generate_inventory_csv(report)
      require "csv"
      
      CSV.generate(headers: true) do |csv|
        csv << ["SKU", "Produto", "Variante", "Estoque", "Preco"]
        
        (report[:low_stock] + report[:out_of_stock]).each do |item|
          csv << [item[:sku], item[:product_name], item[:variant_name], item[:stock], item[:price]]
        end
      end
    end
  end
end
