function OnLoad() {

    document.documentElement.style.webkitTouchCallout = "none"; //禁止弹出菜单

    document.documentElement.style.webkitUserSelect = "none"; //禁止选中

}

var render = function(data) {

    if (data.num && data.time) {
        Highcharts.chart('container', {

            chart: {
                height: 250,
                type: 'spline',
                backgroundColor: 'rgba(0,0,0,0)'
            },
            plotOptions: {
                series: {
                    shadow: true
                }
            },
            title: {
                floating: true,
                text: ''
            },
            xAxis: [{
                categories: data.xAxis,
                crosshair: true
            }],
            yAxis: [{
                title: {
                    text: '次数/次'
                }
            }, {
                title: {
                    text: '时间/分钟'
                },
                opposite: true
            }],
            legend: {
                layout: 'vertical',
                align: 'right',
                verticalAlign: 'middle'
            },
            credits: {
                enabled: false // 禁用版权信息
            },

            series: [{
                name: '当日累计/(次数)',
                data: data.num,
                color: "#90ed7d",
                yAxis: 0
            }, {
                name: '当日累计/(分钟)',
                data: data.time,
                color: "#8085e9",
                yAxis: 1
            }],

            responsive: {
                rules: [{
                    condition: {
                        maxWidth: 500
                    },
                    chartOptions: {
                        legend: {
                            layout: 'horizontal',
                            align: 'center',
                            verticalAlign: 'bottom'
                        }
                    }
                }]
            }

        });
    } else if (data.num && !data.time) {
        Highcharts.chart('container', {

            chart: {
                height: 250,
                type: 'spline'
            },
            title: {
                floating: true,
                text: ''
            },
            xAxis: [{
                categories: data.xAxis,
                crosshair: true
            }],
            yAxis: [{
                title: {
                    text: '次数/次'
                }
            }],
            legend: {
                layout: 'vertical',
                align: 'right',
                verticalAlign: 'middle'
            },
            credits: {
                enabled: false // 禁用版权信息
            },

            series: [{
                name: '当日累计/(次数)',
                data: data.num,
                color: "#90ed7d",
                yAxis: 0
            }],

            responsive: {
                rules: [{
                    condition: {
                        maxWidth: 500
                    },
                    chartOptions: {
                        legend: {
                            layout: 'horizontal',
                            align: 'center',
                            verticalAlign: 'bottom'
                        }
                    }
                }]
            }

        });

    } else if (!data.num && data.time) {
        Highcharts.chart('container', {

            chart: {
                height: 250,
                type: 'spline'
            },
            title: {
                floating: true,
                text: ''
            },
            xAxis: [{
                categories: data.xAxis,
                crosshair: true
            }],
            yAxis: [{
                title: {
                    text: '时间/分钟'
                },
                opposite: true
            }],
            legend: {
                layout: 'vertical',
                align: 'right',
                verticalAlign: 'middle'
            },
            credits: {
                enabled: false // 禁用版权信息
            },

            series: [{
                name: '当日累计/分钟',
                data: data.time,
                color: "#8085e9",
                yAxis: 0
            }],

            responsive: {
                rules: [{
                    condition: {
                        maxWidth: 500
                    },
                    chartOptions: {
                        legend: {
                            layout: 'horizontal',
                            align: 'center',
                            verticalAlign: 'bottom'
                        }
                    }
                }]
            }

        });

    }



}