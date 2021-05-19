import { Controller } from "stimulus"

let majorCustomerContractsDashboard;

export default class extends Controller {
  connect() {
    majorCustomerContractsDashboard = echarts.init(document.getElementById('major-customer-contracts-dashboard'));

    // https://gallery.echartsjs.com/editor.html?c=x_2HiyllXb

    const maxData = 2000;

    const option = {
        backgroundColor: '#f9f9f9',
        tooltip: {},
        xAxis: {
            max: maxData,
            splitLine: {
                show: false
            },
            offset: 10,
            axisTick: {
                show: false
            },
            axisLine: {
                show: false
            },
            axisLabel: {
                show: false
            }
        },
        yAxis: {
            data: ['2018', '2019', '2020'],
            inverse: true,
            axisTick: {
              show: false
            },
            axisLine: {
              show: false
            },
            axisLabel: {
              margin: 10,
              color: '#999',
              fontSize: 16
            }
        },
        grid: {
            top: 'center',
            height: 150,
            left: 55,
            right: 70
        },
        series: [{ // 外边框
                name: '',
                type: 'pictorialBar',
                symbol: 'reat',
                //barWidth: '10%',
                symbolOffset: ['-1%', 0], //位置
                symbolSize: ['102%', 24],
                itemStyle: {
                  color: 'rgba(54,215,182,0.27)'
                },
                z: -180, //图层
                symbolRepeat: null,
                symbolBoundingData: maxData,
                data: [891, 1220, 660],
                animationEasing: 'elasticOut',

            },
            { // 内边框
                name: '',
                type: 'pictorialBar',
                symbol: 'reat',
                //barWidth: '9%',
                //barMaxWidth: '20%',
                symbolOffset: ['-0.5%', 0],
                symbolSize: ['101%', 22],
                itemStyle: {
                  color: 'black'
                },
                z: -20,
                symbolRepeat: null,
                symbolBoundingData: maxData,
                data: [891, 1220, 660],
                animationEasing: 'elasticOut',

            },


            {
                // current data
                type: 'pictorialBar',
                symbol: 'rect',
                itemStyle: {
                  barBorderRadius: 5,
                  color: '#36d7b6',
                },
                symbolRepeat: 'fixed',
                symbolMargin: '5%',
                symbolClip: true,
                symbolSize: 20,
                symbolBoundingData: maxData,
                data: [891, 1220, 660],
                z: 99999999,
                animationEasing: 'elasticOut',
                animationDelay: function(dataIndex, params) {
                    return params.index * 30;
                }
            }, {
                // full data
                type: 'pictorialBar',
                itemStyle: {
                  color: 'rgba(54,215,182,0.27)'
                },
                label: {
                  show: true,
                  formatter: function(params) {
                      return (params.value);
                  },
                  position: 'right',
                  offset: [10, 0],
                  color: 'darkorange',
                  fontSize: 18
                },
                animationDuration: 0,
                symbolRepeat: 'fixed',
                symbolMargin: '5%',
                symbol: 'rect',
                symbolSize: 20,
                symbolBoundingData: maxData,
                data: [891, 1220, 660],
                z: 99999,
                animationEasing: 'elasticOut'
            }
        ]
    };

    majorCustomerContractsDashboard.setOption(option, false);

    setTimeout(() => {
      majorCustomerContractsDashboard.resize();
    }, 200);
  }

  layout() {
    majorCustomerContractsDashboard.resize();
  }

  disconnect() {
    majorCustomerContractsDashboard.dispose();
  }
}
