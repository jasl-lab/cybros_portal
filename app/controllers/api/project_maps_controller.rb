# frozen_string_literal: true

module API
  class ProjectMapsController < WechatMiniBaseController
    before_action :authenticate_wechat_user!
    before_action :make_sure_auth
    before_action :set_map_infos, only: [:show, :list]

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

        {
          title: m.marketinfoname, # 项目名称
          lat: lat,
          lng: lng,
          project_frame_name: m.projectframename, # 案名
          project_code: m.id, # 项目编号
          trace_state: m.tracestate, # 项目状态
          scale_area: m.scalearea, # 规模
          province: m.province, # 省
          city: m.company, # 市
          amounttotal: @is_commercial ? m.amounttotal : nil, # 合同总金额
          is_boutique: !m.isboutiqueproject.nil? && m.isboutiqueproject > 0
        }
      end
    end

    def list
      @list = @map_infos.includes(:project_items).page(params[:page]).per(params[:per_page]).collect do |m|
        lat = m.coordinate.split(',')[1].to_f
        if lat >= 85.051128 || lat <= -85.051128
          Rails.logger.error "coordinate lat error: #{m.id} #{m.marketinfoname} #{m.coordinate}"
        end
        lng = m.coordinate.split(',')[0].to_f
        if lng >= 180 || lng <= -180
          Rails.logger.error "coordinate lng error: #{m.id} #{m.marketinfoname} #{m.coordinate}"
        end
        business_type_deptnames = m.project_items.collect { |c| [c.businesstypecnname, c.projectitemdeptname] }.uniq

        {
          title: m.marketinfoname, # 项目名称
          lat: lat,
          lng: lng,
          project_frame_name: m.projectframename, # 案名
          project_code: m.id, # 项目编号
          trace_state: m.tracestate, # 项目状态
          scale_area: m.scalearea, # 规模
          province: m.province, # 省
          city: m.company, # 市
          amounttotal: @is_commercial ? m.amounttotal : nil, # 合同总金额
          business_type_deptnames: business_type_deptnames
          is_boutique: !m.isboutiqueproject.nil? && m.isboutiqueproject > 0
        }
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
      raise Pundit::NotAuthorizedError.new '仅限商务人员访问' unless policy(Bi::NewMapInfo).show?
      @company_short_names = Bi::OrgShortName.company_short_names
      @sas = Bi::SaContract.where(projectcode: params[:project_code]).order(salescontractcode: :asc)
      if @sas.blank?
        @opportunities = Bi::SaProjectOpportunity.where(projectcode: params[:project_code])
      end
    end

    def project_contract
      raise Pundit::NotAuthorizedError.new '仅限商务人员访问' unless policy(Bi::NewMapInfo).show?
      @sc = Bi::SaContract.find_by salescontractid: params[:id]
    end

    private

      def set_map_infos
        @is_commercial = policy(Bi::NewMapInfo).show?
        province = params[:province].presence && params[:province].strip
        city = params[:city].presence && params[:city].strip
        city = if city.present?
          city.split(',').uniq.join('|')
        else
          city
        end
        client = params[:client].presence && params[:client].strip
        trace_state = params[:trace_state].presence && params[:trace_state].strip
        trace_state = if @is_commercial && trace_state.blank?
          all_tracestates
        elsif @is_commercial && trace_state.present?
          params[:trace_state].split(',')
        else
          '跟踪成功'
        end
        year = params[:year].presence && params[:year].strip
        year = if year.blank?
          year
        else
          year.split(',')
        end

        business_type = params[:business_type].presence && params[:business_type].strip
        cur_business_types = if business_type.present?
          all_business_types.select do |item|
            item[:value].is_a?(Array) ? item[:value].include?(business_type) : item[:value] === business_type
          end
        else
          all_business_types
        end

        project_type = params[:project_type].presence && params[:project_type].strip
        cur_project_types = if project_type.present?
          cur_business_types.collect { |item| item[:project_types] }.flatten.select do |item|
            item[:value].is_a?(Array) ? item[:value].include?(project_type) : item[:value] === project_type
          end
        else
          cur_business_types.collect { |item| item[:project_types] }.flatten
        end

        service_stage = params[:service_stage].presence && params[:service_stage].strip
        cur_service_stages = if service_stage.present?
          cur_project_types.collect { |item| item[:service_stages] }.flatten.select do |item|
            item[:value].is_a?(Array) ? item[:value].any?{ |it| service_stage.split(',').include?(it) } : service_stage.split(',').include?(item[:value])
          end
        else
          cur_project_types.collect { |item| item[:service_stages] }.flatten
        end

        project_process = params[:project_process].presence && params[:project_process].strip

        big_stage = if project_process.present?
          all_project_processes.select { |item| item[:value] === project_process }.collect { |item| item[:big_stage] }.flatten.join('|')
        elsif service_stage.present?
          cur_service_stages.collect { |item| item[:big_stages] }.flatten.collect { |item| item[:value] }.flatten.uniq.join('|')
        else
          ''
        end

        company = params[:company].presence && params[:company].strip
        department = params[:department].presence && params[:department].strip
        scales = params[:scales].presence && params[:scales].strip
        keywords = params[:keywords].presence && params[:keywords].strip

        map_infos = Bi::NewMapInfo.where.not(coordinate: nil)
        map_infos = map_infos.where('instr(coordinate, ?) > 0', ',')
        if province.present?
          map_infos = map_infos.where('province LIKE ?', "%#{province}%")
          map_infos = map_infos.where('company REGEXP ?', city) if city.present?
        end
        projecttype_reg = "(#{business_type || '[^-]+'})-(#{project_type || '[^-]+'})-(#{big_stage || '[^-]+'})"
        map_infos = map_infos.where('projecttype REGEXP ?', "(^#{projecttype_reg})|(,#{projecttype_reg})")
        map_infos = map_infos.where('milestonesname LIKE ?', "%#{project_process}%") if project_process.present?
        map_infos = map_infos.where('developercompanyname LIKE ?', "%#{client}%") if client.present?
        if scales.present? && scales.match(/^\d+(\.\d*)?,\d+(\.\d*)?$/)
          scales = scales.split(',')
          map_infos = map_infos.where(scalearea: scales[0].to_f..scales[1].to_f)
        end
        if company.present?
          map_infos = map_infos.where('maindeptname REGEXP ?', "#{company}-?#{department || '.+'}")
        end
        map_infos = map_infos.where(tracestate: trace_state)
        map_infos = map_infos.where('YEAR(CREATEDDATE) IN (?)', year) if @is_commercial && year.present?
        if keywords.present?
          map_infos = map_infos
            .where('marketinfoname LIKE ? OR projectframename LIKE ? OR ID LIKE ?',
              "%#{keywords}%", "%#{keywords}%", "%#{keywords}%")
        end
        @map_infos = map_infos.order(CREATEDDATE: :desc)
      end

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
            value: '方案报批通过',
            business_type: '土建',
            big_stage: '前端',
          },
          {
            value: '审图通过',
            business_type: '土建',
            big_stage: '后端'
          },
          {
            value: '竣工验收',
            business_type: '土建',
            big_stage: ['前端', '后端'],
          },
        ]
      end

      def all_companies
        companies = Bi::OrgReportRelationOrder.where(isbusinessunit: 'Y').where.not(order_nc: nil).where('`order_nc` < 1000').where(depttype: '普通').where('`name` <> `upname`').where('`startdate` <= curdate()').where('(`enddate` >= curdate() or `enddate` is null)').order(order_nc: :asc).all
        company_codes = companies.collect { |item| item.code }
        departments = Bi::OrgReportRelationOrder.where(isbusinessunit: 'N').where.not(order: nil).where('`order` < 1000').where(depttype: '普通').where(upcode: company_codes).where('`startdate` <= curdate()').where('(`enddate` >= curdate() or `enddate` is null)').order(order: :asc).all
        short_names = Bi::OrgShortName.where(code: company_codes).where(isbusinessunit: 'Y').all
        companies.collect do |company|
          company_short_name = short_names.detect { |item| item.code == company.code }
          {
            label: company_short_name.present? && company_short_name.shortname.present? ? company_short_name.shortname : company.name,
            value: company.name,
            departments: departments.select { |department| department.upcode == company.code }.collect do |department|
              {
                label: department.name,
                value: department.name,
              }
            end
          }
        end
      end

      def all_tracestates
        %w[跟踪中 跟踪成功 仅投标拿地协议 跟踪失败]
      end
  end
end
