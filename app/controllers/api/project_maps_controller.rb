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

      business_type = params[:business_type].presence
      cur_business_types = if business_type.present?
        all_business_types.select do |item|
          item[:value].is_a?(Array) ? item[:value].include(business_type) : item[:value] === business_type
        end
      else
        all_business_types
      end
      business_type = cur_business_types.collect{|item| item[:value]}.flatten.uniq.join('|')

      project_type = params[:project_type].presence && params[:project_type].strip
      cur_project_types = if project_type.present?
        cur_business_types.collect{|item| item[:project_types]}.flatten.select do |item|
          item[:value].is_a?(Array) ? item[:value].include(project_type) : item[:value] === project_type
        end
      else
        cur_business_types.collect{|item| item[:project_types]}.flatten
      end
      project_type = cur_project_types.collect{|item| item[:value]}.flatten.uniq.join('|')

      service_stage = params[:service_stage].presence && params[:service_stage].strip
      cur_service_stages = if service_stage.present?
        cur_project_types.collect{|item| item[:service_stages]}.flatten.select do |item|
          item[:value].is_a?(Array) ? item[:value].include(service_stage) : item[:value] === service_stage
        end
      else
        cur_project_types.collect{|item| item[:service_stages]}.flatten
      end
      service_stage = cur_service_stages.collect{|item| item[:value]}.flatten.uniq.join('|')

      project_process = params[:project_process].presence && params[:project_process].strip

      big_stage = if project_process.present?
        all_project_processes.select{|item| item[:value] === project_process}.collect{|item| item[:big_stage]}.join('|')
      else
        cur_service_stages.collect{|item| item[:big_stages]}.flatten.collect{|item| item[:value]}.flatten.uniq.join('|')
      end

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
      map_infos = map_infos.where('projecttype REGEXP ?', "(^(#{business_type})-(#{project_type})-(#{big_stage}))|(,(#{business_type})-(#{project_type})-(#{big_stage}))")
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
                value: ['公建', '住宅', '工业'],
                service_stages: [
                  {
                    value: '方案',
                    big_stages: [
                      { value: '前端' },
                    ]
                  },
                  {
                    value: '施工图',
                    big_stages: [
                      { value: '后端' },
                    ]
                  },
                  {
                    value: '咨询',
                    big_stages: [
                      { value: '咨询' },
                    ]
                  },
                  {
                    value: '标准化',
                    big_stages: [
                      { value: '标准化' },
                    ]
                  },
                ],
              },
            ]
          },
          {
            value: '规划',
            project_types: [
              {
                value: '法定规划',
                service_stages: [
                  {
                    value: '方案',
                    big_stages: [
                      { value: ['城市总体规划', '控制性详细规划', '修建性详细规划'] },
                    ]
                  }
                ],
              },
              {
                value: '非法定规划',
                service_stages: [
                  {
                    value: '方案',
                    big_stages: [
                      { value: ['策划咨询', '专项研究', '概念规划', '城市设计'] },
                    ]
                  }
                ],
              },
            ]
          },
          {
            value: '室内',
            project_types: [
              {
                value: ['住宅公区', '商办公区', '酒店', '精装修'],
                service_stages: [
                  {
                    value: '方案',
                    big_stages: [
                      { value: '前端' },
                    ]
                  },
                  {
                    value: '施工图',
                    big_stages: [
                      { value: '后端' },
                    ]
                  },
                  {
                    value: '咨询',
                    big_stages: [
                      { value: '咨询' },
                    ]
                  },
                ],
              },
              {
                value: '租赁办公',
                service_stages: [
                  {
                    value: '方案',
                    big_stages: [
                      { value: '办公设计' }
                    ]
                  },
                  {
                    value: '咨询',
                    big_stages: [
                      { value: '咨询' }
                    ]
                  },
                ],
              },
              {
                value: '租赁商业',
                service_stages: [
                  {
                    value: '方案',
                    big_stages: [
                      { value: '商业设计' }
                    ]
                  },
                  {
                    value: '咨询',
                    big_stages: [
                      { value: '咨询' }
                    ]
                  },
                ],
              },
            ]
          },
          {
            value: '景观',
            project_types: [
              {
                value: ['住宅', '公建', '市政'],
                service_stages: [
                  {
                    value: '方案',
                    big_stages: [
                      { value: '前端' }
                    ]
                  },
                  {
                    value: '咨询',
                    big_stages: [
                      { value: '后端' }
                    ]
                  },
                ],
              },
            ]
          },
        ]
      end

      def all_project_processes
        [
          {
            value: '土建-前端-方案报批通过、竣工验收',
            business_type: '土建',
            big_stage: '前端',
          },
          {
            value: '土建-后端-审图通过、竣工验收',
            business_type: '土建',
            big_stage: '后端'
          }
        ]
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
