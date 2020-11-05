package org.seckill.dao.cache;

import org.seckill.entity.Seckill;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.dyuproject.protostuff.LinkedBuffer;
import com.dyuproject.protostuff.ProtostuffIOUtil;
import com.dyuproject.protostuff.runtime.RuntimeSchema;

import redis.clients.jedis.Jedis;
import redis.clients.jedis.JedisPool;

public class RedisDao {
	
	private Logger logger = LoggerFactory.getLogger(this.getClass());
	
	private final JedisPool jedisPool;
	
	public RedisDao(String ip,int port){
		jedisPool = new JedisPool(ip, port);
	}
	
	private RuntimeSchema<Seckill> schema = RuntimeSchema.createFrom(Seckill.class);
	
	public Seckill getSeckill(long seckillId){
		//redis操作逻辑
		Jedis jedis = null;
		try {
			jedis = jedisPool.getResource();
			String key = "seckill:"+seckillId;
			//并没有实现内部序列化操作
			//get->byte[] ->反序列化 ->Object(Seckill)
			//采用自定义序列化(protostuff)  节省内存，对象的大小，和cpu的空间.(比java自带的序列化机制要节省1/5的空间)
			//protostuff : pojo.
			byte[] bytes = jedis.get(key.getBytes());
			//缓存重获取到
			if(bytes!=null){
				//空对象
				Seckill seckill = schema.newMessage();
				ProtostuffIOUtil.mergeFrom(bytes, seckill, schema);
				//seckill 被反序列化
				return seckill;
			}
			
			
		} catch (Exception e) {
			logger.error(e.getMessage(),e);
		}finally{
			if(jedis!=null){
				jedis.close();
			}
			
		}
		return null;
	}
	
	public String putSeckill(Seckill seckill){
		//Set object(Seckill) ->序列化--> byte[]
		Jedis jedis = null;
		try {
			jedis = jedisPool.getResource();
			String key = "seckill:"+seckill.getSeckillId();
			byte[] bytes = ProtostuffIOUtil.toByteArray(seckill, schema, 
					LinkedBuffer.allocate(LinkedBuffer.DEFAULT_BUFFER_SIZE));
			//超时缓存(单位为秒)
			int timeout = 60*60;
			String result = jedis.setex(key.getBytes(), timeout , bytes);
			return result;
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}finally {
			if(jedis!=null){
				jedis.close();
			}
		}
		return null;
	}
	
}
