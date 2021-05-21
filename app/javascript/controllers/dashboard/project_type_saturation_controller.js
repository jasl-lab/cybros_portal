import { Controller } from "stimulus"

let projectTypeSaturationDashboard;

export default class extends Controller {
  connect() {
    projectTypeSaturationDashboard = echarts.init(document.getElementById('project-type-saturation-dashboard'));
    // https://gallery.echartsjs.com/editor.html?c=xAqxk9ZhVv


    const data = [
    {
      name: '方案饱和度',
      subtext: '参考值: 95%',
      value: 92
    },{
      name: '施工图饱和度',
      subtext: '参考值: 80%',
      value: 81
    },{
      name: '非建筑饱和度',
      subtext: '参考值: 95%',
      value: 96
    }];

    const titleArr= [], seriesArr=[];
    const colors=[['#389af4', '#dfeaff'],['#ff8c37', '#ffdcc3'],['#ffc257', '#ffedcc'], ['#fd6f97', '#fed4e0'],['#a181fc', '#e3d9fe']]
    data.forEach(function(item, index){
        titleArr.push(
            {
                text:item.name,
                subtext: item.subtext,
                left: index * 32 + 17 +'%',
                top: '70%',
                textAlign: 'center',
                textStyle: {
                    fontWeight: 'normal',
                    fontSize: '14',
                    color: colors[index][0],
                    textAlign: 'center',
                },
            }
        );
        seriesArr.push(
            {
                name: item.name,
                type: 'pie',
                clockwise: false,
                radius: [30, 40],
                itemStyle:  {
                    normal: {
                        color: colors[index][0],
                        shadowColor: colors[index][0],
                        shadowBlur: 0,
                        label: {
                            show: false
                        },
                        labelLine: {
                            show: false
                        },
                    }
                },
                emphasis: {
                  scale: false
                },
                center: [index * 32 + 17 +'%', '35%'],
                data: [{
                    value: item.value,
                    label: {
                        normal: {
                            formatter: function(params){
                                return params.value+'%';
                            },
                            position: 'center',
                            show: true,
                            textStyle: {
                                fontSize: '16',
                                fontWeight: 'bold',
                                color: colors[index][0]
                            }
                        }
                    },
                }, {
                    value: 100-item.value,
                    name: 'invisible',
                    itemStyle: {
                        normal: {
                            color: colors[index][1]
                        },
                        emphasis: {
                            color: colors[index][1]
                        }
                    }
                }]
            }
        )
    });


    const option = {
        backgroundColor: "#fff",
        title:titleArr,
        series: seriesArr
    }

    projectTypeSaturationDashboard.setOption(option, false);

    setTimeout(() => {
      projectTypeSaturationDashboard.resize();
    }, 200);
  }

  layout() {
    projectTypeSaturationDashboard.resize();
  }

  disconnect() {
    projectTypeSaturationDashboard.dispose();
  }
}
