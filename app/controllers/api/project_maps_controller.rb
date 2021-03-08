# frozen_string_literal: true

module API
  class ProjectMapsController < WechatMiniBaseController
    before_action :authenticate_wechat_user!
    before_action :make_sure_auth
    before_action only: [:show, :list] do
      is_commercial = policy(Bi::NewMapInfo).show?
      province = params[:province].presence && params[:province].strip
      city = params[:city].presence && params[:city].strip
      client = params[:client].presence && params[:client].strip
      trace_state = params[:trace_state].presence && params[:trace_state].strip
      trace_state = if is_commercial && trace_state.blank?
        all_tracestates
      elsif is_commercial && trace_state.present?
        params[:trace_state]
      else
        '跟踪成功'
      end
      year = params[:year].presence && params[:year].strip
      default_business_type = all_business_types.collect{|item| item[:value]}.uniq
      default_project_type = all_business_types.collect{|item| item[:project_types]}.flatten.collect{|item| item[:value]}.uniq
      default_service_stage = all_business_types.collect{|item| item[:project_types]}.flatten.collect{|item| item[:service_stages]}.flatten.uniq
      business_type = params[:business_type].presence && params[:business_type].strip || default_business_type.join('|')
      project_type = params[:project_type].presence && params[:project_type].strip || default_project_type.join('|')
      service_stage = params[:service_stage].presence && params[:service_stage].strip || default_service_stage.join('|')
      company = params[:company].presence && params[:company].strip
      department = params[:department].presence && params[:department].strip
      scales = params[:scales].presence && params[:scales].strip
      keywords = params[:keywords].presence && params[:keywords].strip

      map_infos = Bi::NewMapInfo.where.not(coordinate: nil).includes(:project_items)
      map_infos = map_infos.where('instr(coordinate, ?) > 0', ',')
      if province.present?
        map_infos = map_infos.where('province LIKE ?', "%#{province}%")
        map_infos = map_infos.where('company LIKE ?', "%#{city}%") if city.present?
      end
      map_infos = map_infos.where('projecttype REGEXP ?', "(^(#{business_type})-(#{project_type})-(#{service_stage}))|(,(#{business_type})-(#{project_type})-(#{service_stage}))")
      map_infos = map_infos.where('developercompanyname LIKE ?', "%#{client}%") if client.present?
      if scales.present? && scales.match(/^\d+(\.\d*)?,\d+(\.\d*)?$/)
        scales = scales.split(',')
        map_infos = map_infos.where(scalearea: scales[0].to_f..scales[1].to_f)
      end
      if company.present?
        map_infos = map_infos.where('maindeptname REGEXP ?', "#{company}-?#{department || '.+'}")
      end
      map_infos = map_infos.where(tracestate: trace_state)
      if is_commercial
        map_infos = map_infos.where('YEAR(CREATEDDATE) = ?', year) if is_commercial && year.present?
      end
      if keywords.present?
        map_infos = map_infos
          .where('marketinfoname LIKE ? OR projectframename LIKE ? OR ID LIKE ?',
            "%#{keywords}%", "%#{keywords}%", "%#{keywords}%")
      end
      @map_infos = map_infos
    end

    def show
      @valid_map_points = @map_infos.collect do |m|
        lat = m.coordinate.split(',')[1].to_f
        if lat >= 85.051128 || lat <= -85.051128
          Rails.logger.error "coordinate lat error: #{m.id} #{m.marketinfoname} #{m.coordinate}"
        end
        lng = m.coordinate.split(',')[0].to_f
        if lng >= 180 || lng <= -180
          Rails.logger.error "coordinate lng error: #{m.id} #{m.marketinfoname} #{m.coordinate}"
        end
        business_type_deptnames = m.project_items.collect { |c| [c.businesstypecnname, c.projectitemdeptname] }.uniq

        { title: m.marketinfoname, # 项目名称
          lat: lat,
          lng: lng,
          project_frame_name: m.projectframename, # 案名
          project_code: m.id, # 项目编号
          trace_state: m.tracestate, # 项目状态
          scale_area: m.scalearea, # 规模
          province: m.province, # 省
          city: m.company, # 市
          business_type_deptnames: business_type_deptnames }
      end
    end

    def list
      @list = @map_infos.page(params[:page]).per(params[:per_page]).collect do |m|
        lat = m.coordinate.split(',')[1].to_f
        if lat >= 85.051128 || lat <= -85.051128
          Rails.logger.error "coordinate lat error: #{m.id} #{m.marketinfoname} #{m.coordinate}"
        end
        lng = m.coordinate.split(',')[0].to_f
        if lng >= 180 || lng <= -180
          Rails.logger.error "coordinate lng error: #{m.id} #{m.marketinfoname} #{m.coordinate}"
        end
        business_type_deptnames = m.project_items.collect { |c| [c.businesstypecnname, c.projectitemdeptname] }.uniq

        { title: m.marketinfoname, # 项目名称
          lat: lat,
          lng: lng,
          project_frame_name: m.projectframename, # 案名
          project_code: m.id, # 项目编号
          trace_state: m.tracestate, # 项目状态
          scale_area: m.scalearea, # 规模
          province: m.province, # 省
          city: m.company, # 市
          business_type_deptnames: business_type_deptnames }
      end

      @total = @map_infos.count
    end

    def query_config
      if policy(Bi::NewMapInfo).show?
        @tracestates = all_tracestates
        @createddate_years = Bi::NewMapInfo.all_createddate_year
        @createddate_years = @createddate_years.map { |item| item }
        @createddate_years.shift
      end
      @business_types = all_business_types
      @project_processes = all_project_processes
      @companies = all_companies
    end

    def project
      @project = Bi::NewMapInfo.find_by(id: params[:project_code])
      @project_items = Edoc2::ProjectInfo.where(projectcode: params[:project_code]).order(projectitemcode: :asc)
    end

    def project_contracts
      @sas = Bi::SaContract.where(projectcode: params[:project_code]).order(salescontractcode: :asc)
      if @sas.blank?
        @opportunities = Bi::SaProjectOpportunity.where(projectcode: params[:project_code])
      end
    end

    def project_contract
      @sc = Bi::SaContract.find_by salescontractid: params[:id]
    end

    private
      def all_business_types
        [
          {
            value: '土建',
            project_types: [
              {
                value: '公建',
                service_stages: ['方案', '施工图', '咨询', '标准化'],
              },
              {
                value: '住宅',
                service_stages: ['方案', '施工图', '咨询', '标准化'],
              },
              {
                value: '工业',
                service_stages: ['方案', '施工图', '咨询', '标准化'],
              },
            ]
          },
          {
            value: '规划',
            project_types: [
              {
                value: '法定规划',
                service_stages: ['方案'],
              },
              {
                value: '非法定规划',
                service_stages: ['方案'],
              },
            ]
          },
          {
            value: '室内',
            project_types: [
              {
                value: '住宅公区',
                service_stages: ['方案', '施工图', '咨询'],
              },
              {
                value: '商办公区',
                service_stages: ['方案', '施工图', '咨询'],
              },
              {
                value: '酒店',
                service_stages: ['方案', '施工图', '咨询'],
              },
              {
                value: '精装修',
                service_stages: ['方案', '施工图', '咨询'],
              },
              {
                value: '租赁办公',
                service_stages: ['方案', '咨询'],
              },
              {
                value: '租赁商业',
                service_stages: ['方案', '咨询'],
              },
            ]
          },
          {
            value: '景观',
            project_types: [
              {
                value: '住宅',
                service_stages: ['方案', '咨询'],
              },
              {
                value: '公建',
                service_stages: ['方案', '咨询'],
              },
              {
                value: '市政',
                service_stages: ['方案', '咨询'],
              },
            ]
          },
        ]
      end

      def all_project_processes
        ['土建-前端-方案报批通过、竣工验收', '土建-后端-审图通过、竣工验收']
      end
      def all_companies
        companies = Bi::OrgReportDeptOrder.where('是否显示 = 1').order(组织: :asc, 显示顺序: :asc).all
        companies.collect do |company|
          {
            company: company.组织,
            department: company.部门,
          }
        end
      end
      def all_tracestates
        %w[跟踪中 跟踪成功 仅投标拿地协议 跟踪失败]
      end
  end
end
