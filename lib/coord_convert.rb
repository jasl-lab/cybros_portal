class CoordConvert
  class << self
    PI = 3.14159265358979324
    X_PI = PI * 3000.0 / 180.0 #圆周率转换量
    ## Krasovsky 1940
    ## a = 6378245.0, 1/f = 298.3
    ## b = a * (1 - f)
    ## ee = (a^2 - b^2) / a^2
    A = 6378245.0 #椭球体的长半轴半径
    EE = 0.00669342162296594323 #椭球体的第一偏心率

    def convert(from,to,lng,lat)
      if from == 'bd09' && to == 'gcj02'
        return bd09_to_gcj02(lng,lat)
      elsif from == 'gcj02' && to == 'bd09'
        return gcj02_to_db09(lng,lat)
      elsif from == 'wgs84' && to == 'gcj02'
        return wgs84_to_gcj02(lng,lat)
      elsif from == 'gcj02' && to == 'wgs84'
        return gcj02_to_wgs84(lng,lat)
      else
        raise ArgumentError.new "only support 'bd09' to 'gjc', 'gcj02' to 'bd09', 'wgs84' to 'gcj02' and 'gcj02' to 'wgs84' "
      end
    end

    private

    def bd09_to_gcj02(lng,lat)
      x = lng - 0.0065
      y = lat - 0.006
      z = Math.sqrt(x * x + y * y) - 0.00002 * Math.sin(y * X_PI)
      theta = Math.atan2(y, x) - 0.000003 * Math.cos(x * X_PI);
      gcj_lng = z * Math.cos(theta);
      gcj_lat = z * Math.sin(theta);
      return gcj_lng,gcj_lat
    end

    def gcj02_to_db09(lng,lat)
      x = lng
      y = lat
      z = Math.sqrt(x * x + y * y) + 0.00002 * Math.sin(y * X_PI)
      theta = Math.atan2(y, x) + 0.000003 * Math.cos(x * X_PI)
      bd_lng = z * Math.cos(theta) + 0.0065
      bd_lat = z * Math.sin(theta) + 0.006
      return bd_lng, bd_lat
    end

    def wgs84_to_gcj02(lng, lat)
      return lng, lat if out_of_china(lng, lat)

      d_lat = trans_form_lat(lng - 105.0, lat - 35.0)
      d_lng = trans_form_lng(lng - 105.0, lat - 35.0)
      rad_lat = lat / 180.0 * PI
      magic = Math.sin(rad_lat)
      magic = 1 - EE * magic * magic
      sqrt_magic = Math.sqrt(magic)
      d_lng = (d_lng * 180.0) / (A / sqrt_magic * Math.cos(rad_lat) * PI)
      d_lat = (d_lat * 180.0) / ((A * (1 - EE)) / (magic * sqrt_magic) * PI)
      gcj_lng = lng + d_lng
      gcj_lat = lat + d_lat
      return gcj_lng, gcj_lat
    end

    def gcj02_to_wgs84(lng, lat)
      return lng, lat if out_of_china(lng, lat)
      d_lat = trans_form_lat(lng - 105.0, lat - 35.0)
      d_lng = trans_form_lng(lng - 105.0, lat - 35.0)
      rad_lat = lat / 180.0 * PI
      magic = Math.sin(rad_lat)
      magic = 1 - EE * magic * magic
      sqrt_magic = Math.sqrt(magic)
      d_lat = (d_lat * 180.0) / ((A * (1 - EE)) / (magic * sqrt_magic) * PI)
      d_lng = (d_lng * 180.0) / (A / sqrt_magic * Math.cos(rad_lat) * PI)
      wgs_lat = lat + d_lat
      wgs_lng = lng + d_lng
      return lng * 2 - wgs_lng, lat * 2 - wgs_lat
    end

    def trans_form_lat(lng, lat)
      ret = -100.0 + 2.0 * lng + 3.0 * lat + 0.2 * lat * lat + 0.1 * lng * lat + 0.2 * Math.sqrt(lng.abs)
      ret += (20.0 * Math.sin(6.0 * lng * PI) + 20.0 * Math.sin(2.0 * lng * PI)) * 2.0 / 3.0
      ret += (20.0 * Math.sin(lat * PI) + 40.0 * Math.sin(lat / 3.0 * PI)) * 2.0 / 3.0
      ret += (160.0 * Math.sin(lat / 12.0 * PI) + 320 * Math.sin(lat * PI / 30.0)) * 2.0 / 3.0
      return ret
    end

    def trans_form_lng(lng, lat)
      ret = 300.0 + lng + 2.0 * lat + 0.1 * lng * lng + 0.1 * lng * lat + 0.1 * Math.sqrt(lng.abs)
      ret += (20.0 * Math.sin(6.0 * lng * PI) + 20.0 * Math.sin(2.0 * lng * PI)) * 2.0 / 3.0
      ret += (20.0 * Math.sin(lng * PI) + 40.0 * Math.sin(lng / 3.0 * PI)) * 2.0 / 3.0
      ret += (150.0 * Math.sin(lng / 12.0 * PI) + 300.0 * Math.sin(lng / 30.0 * PI)) * 2.0 / 3.0
      return ret
    end

    def out_of_china(lng, lat)
      if ((72.0040..137.8347).include? lng) && ((0.8293..55.8271).include? lat)
        return true
      else
        return false
      end
    end
  end
end
