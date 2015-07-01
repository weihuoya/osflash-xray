# Introduction #

The Flex2 SWC includes the logger and inspector for AS3 and Flex2.


# Details #

To create a new instance of Xray for your application, just import Flex2Xray:

```
import com.blitzagency.xray.inspector.flex2.Flex2Xray;

//then, create the instance:

private var xray:Flex2Xray = new Flex2Xray();
```

For logging:

```
private var log:XrayLog = new XrayLog();

log.debug("stringMessage"[,obj_0, obj_1, ...rest]);
log.info("stringMessage"[,obj_0, obj_1, ...rest]);
log.warn("stringMessage"[,obj_0, obj_1, ...rest]);
log.error("stringMessage"[,obj_0, obj_1, ...rest]);
log.fatal("stringMessage"[,obj_0, obj_1, ...rest]);
```

If you want to just use the logger without inspection:

```
import com.blitzagency.xray.logger.XrayLog;

private var log:XrayLog = new XrayLog();

log.debug("stringMessage"[,obj_0, obj_1, ...rest]);
log.info("stringMessage"[,obj_0, obj_1, ...rest]);
log.warn("stringMessage"[,obj_0, obj_1, ...rest]);
log.error("stringMessage"[,obj_0, obj_1, ...rest]);
log.fatal("stringMessage"[,obj_0, obj_1, ...rest]);

```



