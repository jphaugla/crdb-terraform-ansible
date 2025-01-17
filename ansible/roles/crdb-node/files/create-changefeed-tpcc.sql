CREATE CHANGEFEED FOR TABLE tpcc.customer, tpcc.district, tpcc.history, tpcc.item, tpcc.new_order, tpcc.order, tpcc.order_line, tpcc.stock, tpcc.warehouse INTO 'webhook-https://20.118.251.74:30004/kv/public?insecure_tls_skip_verify=true' WITH diff, updated, resolved='1s', min_checkpoint_frequency='1s', webhook_sink_config='{"Flush":{"Bytes":1048576,"Frequency":"1s"}}';
