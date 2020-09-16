import { Controller } from "stimulus"

let contractSigningsAmountDashboard;

export default class extends Controller {
  connect() {
    contractSigningsAmountDashboard = echarts.init(document.getElementById('contract-signings-amount-dashboard'));

    // https://gallery.echartsjs.com/editor.html?c=xrQ8h-yf47
    const highlight = '#1e87f0';

    const demoData = [{
            name: '生产合同额',
            value: 22,
            unit: '℃',
            pos: ['25%', '45%'],
            range: [-40, 100],
            YS: [
                [0.4, '#119eff'],
                [0.5, '#30da74'],
                [1, '#f3390d']
            ]
        },
        {
            name: '跟踪合同额',
            value: 90,
            unit: '%',
            pos: ['75%', '45%'],
            range: [0, 100],
            splitNum: 10,
            YS: [
                [0.3, '#f3390d'],
                [0.8, '#30da74'],
                [1, '#119eff']
            ]
        }
    ];

    const option = {
        backgroundColor: '#f9f9f9',
        series: (function() {
            let result = [];

            demoData.forEach(function(item, findex) {
                let radius = (findex == 0 ? '55%' : '20%');
                result.push(
                    // 外围刻度
                    {
                        type: 'gauge',
                        center: item.pos,
                        radius: radius, // 1行2个
                        splitNumber: item.splitNum || 10,
                        min: item.range[0],
                        max: item.range[1],
                        startAngle: 225,
                        endAngle: -45,
                        axisLine: {
                            show: true,
                            lineStyle: {
                                width: 2,
                                shadowBlur: 0,
                                color: [
                                    [1, highlight]
                                ]
                            }
                        },
                        axisTick: {
                            show: true,
                            lineStyle: {
                                color: highlight,
                                width: 1
                            },
                            length: -5,
                            splitNumber: 10
                        },
                        splitLine: {
                            show: true,
                            length: -10,
                            lineStyle: {
                                color: highlight,
                            }
                        },
                        axisLabel: {
                            distance: -18,
                            textStyle: {
                                color: highlight,
                                fontSize: '10',

                            }
                        },
                        pointer: {
                            show: 0
                        },
                        detail: {
                            show: 0
                        }
                    }, {
                        name: item.name,
                        type: 'gauge',
                        center: item.pos,
                        splitNumber: item.splitNum || 10,
                        min: item.range[0],
                        max: item.range[1],
                        radius: '45%',
                        axisLine: { // 坐标轴线
                            show: false,
                            lineStyle: { // 属性lineStyle控制线条样式
                                color: item.YS,
                                shadowColor: "#ccc",
                                shadowBlur: 25,
                                width: 0
                            }
                        },
                        axisLabel: {
                            show: false
                        },
                        axisTick: { // 坐标轴小标记
                            // show: false,
                            length: 20, // 属性length控制线长
                            lineStyle: { // 属性lineStyle控制线条样式
                                color: 'auto',
                                width: 2
                            }
                        },
                        splitLine: { // 分隔线
                            show: false,
                            length: 20, // 属性length控制线长
                            lineStyle: { // 属性lineStyle（详见lineStyle）控制线条样式
                                color: 'auto'
                            }
                        },
                        title: {
                            textStyle: { // 其余属性默认使用全局文本样式，详见TEXTSTYLE
                                fontWeight: 'bolder',
                                fontSize: 20,
                                fontStyle: 'italic'
                            }
                        },
                        detail: {
                            show: true,
                            offsetCenter: [0, '100%'],
                            textStyle: {
                                fontSize: 25
                            },
                            formatter: [
                                '{value} ' + (item.unit || ''),
                                '{name|' + item.name + '}'
                            ].join('\n'),
                            rich: {
                                name: {
                                    fontSize: 16,
                                    lineHeight: 30,
                                    color: '#1e87f0'
                                }
                            }
                        },
                        data: [{
                            value: item.value
                        }],
                        pointer: {
                            width: 5
                        }
                    },
                    // 内侧指针、数值显示
                    {
                        name: item.name,
                        type: 'gauge',
                        center: item.pos,
                        radius: '40%',
                        startAngle: 225,
                        endAngle: -45,
                        min: item.range[0],
                        max: item.range[1],
                        axisLine: {
                            show: true,
                            lineStyle: {
                                width: 16,
                                color: [
                                    [1, 'rgba(30,135,240,.3)']
                                ]
                            }
                        },
                        axisTick: {
                            show: 0,
                        },
                        splitLine: {
                            show: 0,
                        },
                        axisLabel: {
                            show: 0
                        },
                        pointer: {
                            show: true,
                            length: '90%',
                            width: 3,
                        },
                        itemStyle: { //表盘指针的颜色
                            color: 'rgba(255, 153, 0, 0.31)',
                            borderColor: '#ff9900',
                            borderWidth: 1
                        },
                        detail: {
                            show: false,
                            offsetCenter: [0, '100%'],
                            textStyle: {
                                fontSize: 20,
                                color: '#00eff2'
                            },
                            formatter: [
                                '{value} ' + (item.unit || ''),
                                '{name|' + item.name + '}'
                            ].join('\n'),
                            rich: {
                                name: {
                                    fontSize: 14,
                                    lineHeight: 30,
                                    color: '#00eff2'
                                }
                            }
                        },

                        data: [{
                            value: item.value
                        }]
                    }
                );
            });
            return result;
        })()
    };

    contractSigningsAmountDashboard.setOption(option, false);

    setTimeout(() => {
      contractSigningsAmountDashboard.resize();
    }, 200);
  }

  layout() {
    contractSigningsAmountDashboard.resize();
  }

  disconnect() {
    contractSigningsAmountDashboard.dispose();
  }
}
