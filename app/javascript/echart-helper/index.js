function mapProvinceSum2MapData(amount, index) {
  switch(index) {
    case 0:
      return { value: amount, name: '台湾' };
    case 1:
      return { value: amount, name: '河北' };
    case 2:
      return { value: amount, name: '山西' };
    case 3:
      return { value: amount, name: '内蒙古' };
    case 4:
      return { value: amount, name: '辽宁' };
    case 5:
      return { value: amount, name: '吉林' };
    case 6:
      return { value: amount, name: '黑龙江' };

    case 7:
      return { value: amount, name: '江苏' };
    case 8:
      return { value: amount, name: '浙江' };
    case 9:
      return { value: amount, name: '安徽' };
    case 10:
      return { value: amount, name: '福建' };
    case 11:
      return { value: amount, name: '江西' };
    case 12:
      return { value: amount, name: '山东' };
    case 13:
      return { value: amount, name: '河南' };

    case 14:
      return { value: amount, name: '湖北' };
    case 15:
      return { value: amount, name: '湖南' };
    case 16:
      return { value: amount, name: '广东' };
    case 17:
      return { value: amount, name: '广西' };
    case 18:
      return { value: amount, name: '海南' };
    case 19:
      return { value: amount, name: '四川' };
    case 20:
      return { value: amount, name: '贵州' };

    case 21:
      return { value: amount, name: '云南' };
    case 22:
      return { value: amount, name: '西藏' };
    case 23:
      return { value: amount, name: '陕西' };
    case 24:
      return { value: amount, name: '甘肃' };
    case 25:
      return { value: amount, name: '青海' };
    case 26:
      return { value: amount, name: '宁夏' };
    case 27:
      return { value: amount, name: '新疆' };

    case 28:
      return { value: amount, name: '北京' };
    case 29:
      return { value: amount, name: '天津' };
    case 30:
      return { value: amount, name: '上海' };
    case 31:
      return { value: amount, name: '重庆' };
    case 32:
      return { value: amount, name: '香港' };
    case 33:
      return { value: amount, name: '澳门' };
  }
}

export { mapProvinceSum2MapData };
