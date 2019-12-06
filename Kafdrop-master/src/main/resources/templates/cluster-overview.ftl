<#--
 Copyright 2016 HomeAdvisor, Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
-->
<#import "lib/template.ftl" as template>
<@template.header "Broker List"/>

<script src="/js/powerFilter.js"></script>



<#setting number_format="0">
    <div>
        <h2>Kafka Cluster Overview</h2>

        <div id="cluster-overview">
            <table class="table table-bordered">
                <tbody>
                <tr>
                    <td>Zookeeper Host Configuration</td>
                    <td><#list zookeeper.connectList as z>${z}<#if z_has_next>, </#if></#list></td>
                </tr>
                <tr>
                    <td>Total Topics</td>
                    <td>${clusterSummary.topicCount}</td>
                </tr>
                <tr>
                    <td>Total Partitions</td>
                    <td>${clusterSummary.partitionCount}</td>
                </tr>
                <tr>
                    <td>Total Preferred Partition Leader</td>
                    <td <#if clusterSummary.preferredReplicaPercent lt 1.0>class="warning"</#if>>${clusterSummary.preferredReplicaPercent?string.percent}</td>
                </tr>
                <tr>
                    <td>Total Under Replicated Partitions</td>
                    <td <#if clusterSummary.underReplicatedCount gt 0>class="warning"</#if>>${clusterSummary.underReplicatedCount}</td>
                </tr>
                </tbody>
            </table>
        </div>

        <div id="brokers">
            <h3>Brokers</h3>
            <table class="table table-bordered">
                <thead>
                <tr>
                    <th>ID</th>
                    <th>Host</th>
                    <th>Port</th>
                    <th>JMX Port</th>
                    <th>Version</th>
                    <th>
                        Start Time
                        <a title="Time the broker joined the cluster"
                           data-toggle="tooltip" data-placement="top" href="#"
                        ><i class="fa fa-question-circle"></i></a>
                    </th>
                    <th>Controller?</th>
                    <th>
                        # Partitions (% of Total)
                        <a title="# of partitions this broker is the leader for"
                           data-toggle="tooltip" data-placement="top" href="#"
                        ><i class="fa fa-question-circle"></i></a>
                    </th>
                </tr>
                </thead>
                <tbody>
                <#if brokers?size == 0>
                    <tr>
                        <td class="danger text-danger" colspan="8"><i class="fa fa-warning"></i> No brokers available</td>
                    </tr>
                <#elseif missingBrokerIds?size gt 0>
                    <tr>
                        <td class="danger text-danger" colspan="8"><i class="fa fa-warning"></i> Missing brokers: <#list missingBrokerIds as b>${b}<#if b_has_next>, </#if></#list></td>
                    </tr>
                </#if>
                <#list brokers as b>
                <tr>
                    <td><a href="/broker/${b.id}"><i class="fa fa-info-circle fa-lg"></i> ${b.id}</a></td>
                    <td>${b.host}</td>
                    <td>${b.port?string}</td>
                    <td>${b.jmxPort?string}</td>
                    <td>${b.version}</td>
                    <td>${b.timestamp?string["yyyy-MM-dd HH:mm:ss.SSSZ"]}</td>
                    <td><@template.yn b.controller/></td>
                    <td>${(clusterSummary.getBrokerLeaderPartitionCount(b.id))!0} (${(((clusterSummary.getBrokerLeaderPartitionCount(b.id))!0)/clusterSummary.partitionCount)?string.percent})</td>
                </tr>
                </#list>
                </tbody>
            </table>
        </div>

        <div id="topics">
            <h3>Topics</h3>
            <table class="table table-bordered table-condensed">
                <thead>
                <tr>
                    <th>
                        Name

                        <span style="font-weight:normal;">
                            &nbsp;<INPUT id='filter' size=25 NAME='searchRow' title='Just type to filter the rows'>&nbsp;
                            <span id="rowCount"></span>
                        </span>
                    </th>
                    <th>
                        Total<br/>Partitions
                        <a title="Number of partitions in the topic"
                           data-toggle="tooltip" data-placement="top" href="#"
                        ><i class="fa fa-question-circle"></i></a>
                    </th>
                    <th>
                        Replica<br/>Owners
                        <a title="List of brokers owning this topic's data. Format is <brokerId>: <leader count>/<replica count>"
                           data-toggle="tooltip" data-placement="top" href="#"
                        ><i class="fa fa-question-circle"></i></a>
                    </th>
                    <th>
                        Preferred<br/>Leader %
                        <a title="Percent of partitions where the preferred broker has been assigned leadership"
                           data-toggle="tooltip" data-placement="top" href="#"
                        ><i class="fa fa-question-circle"></i></a>
                    </th>
                    <th>
                        # Under<br/>Replicated
                        <a title="Number of partition replicas that are not in sync with the primary partition"
                           data-toggle="tooltip" data-placement="top" href="#"
                        ><i class="fa fa-question-circle"></i></a>
                    </th>
                    <th>Custom<br/>Config?</th>
                </tr>
                </thead>
                <tbody>
                <#if topics?size == 0>
                <tr>
                    <td colspan="5">No topics available</td>
                </tr>
                </#if>
                <#list topics as t>
                <tr class="dataRow">
                    <td><a href="/topic/${t.name}">${t.name}</a></td>
                    <td>${t.partitions?size}</td>
                    <td>
                        <ul class="list-inline">
                            <#assign replicas=t.brokerReplicas>
                            <#list replicas?values as brokerReplicas>
                                <li>${brokerReplicas.brokerId}: <b>${brokerReplicas.leaders?size}</b>/${brokerReplicas.replicas?size}</li>
                            </#list>
                        </ul>
                    </td>
                    <td <#if t.preferredReplicaPercent lt 1.0>class="warning"</#if>>${t.preferredReplicaPercent?string.percent}</td>
                    <td <#if t.underReplicatedPartitions?size gt 0>class="warning"</#if>>${t.underReplicatedPartitions?size}</td>
                    <td>
                        <#assign customConfig=t.config?size gt 0/>
                        <@template.yn customConfig/>
                        <#if customConfig>
                            <#assign configDetails><#list t.config?keys as c>${c}: ${t.config[c]}<#if c_has_next>, </#if></#list></#assign>
                            <a title="${configDetails}"
                               data-toggle="tooltip" data-placement="top" href="#"
                            ><i class="fa fa-info-circle"></i></a>
                        </#if>
                    </td>
                </tr>
                </#list>
                </tbody>
            </table>
        </div>
    </div>

<@template.footer/>

<script>
    $(document).ready(function() {
        $('#filter').focus();

    <#if filter??>
        $('#filter').val('${filter}');
    </#if>
        $('[data-toggle="tooltip"]').tooltip()
    });
</script>
