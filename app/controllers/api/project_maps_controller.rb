# frozen_string_literal: true

module API
  class ProjectMapsController < WechatMiniBaseController
    before_action :authenticate_wechat_user!
    before_action :make_sure_auth

    def show
      authorize Bi::NewMapInfo

      city = params[:city].presence || '所有'
      province = params[:province].presence || '所有'
      client = params[:client].presence

      trace_state = if params[:trace_state].presence.blank?
        # %w[跟踪中 跟踪成功 仅投标拿地协议 跟踪失败]
        '跟踪成功'
      else
        params[:trace_state]
      end
      year = params[:year].presence || '所有'
      project_type = params[:project_type].presence
      keywords = params[:keywords].presence

      map_infos = policy_scope(Bi::NewMapInfo).where.not(coordinate: nil).includes(:project_items)
      map_infos = map_infos.where(tracestate: trace_state)
      map_infos = map_infos.where('YEAR(CREATEDDATE) = ?', year) unless year == '所有'
      map_infos = map_infos.where('company LIKE ?', "%#{city}%") unless city == '所有'
      map_infos = map_infos.where('province LIKE ?', "%#{province}%") unless province == '所有'
      map_infos = map_infos.where('projecttype LIKE ?', "%#{project_type}%") if project_type.present?
      map_infos = map_infos.where('developercompanyname LIKE ?', "%#{client}%") if client.present?
      if keywords.present?
        map_infos = map_infos
          .where('marketinfoname LIKE ? OR projectframename LIKE ? OR ID LIKE ?',
            "%#{keywords}%", "%#{keywords}%", "%#{keywords}%")
      end

      valid_map_infos = map_infos.reject { |m| !m.coordinate.include?(',') }

      @valid_map_points = valid_map_infos.collect do |m|
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
  end

  def config
    authorize Bi::NewMapInfo
    @tracestates = policy_scope(Bi::NewMapInfo).all_tracestates_with_color_hint
    @createddate_years = Bi::NewMapInfo.all_createddate_year
  end
end
