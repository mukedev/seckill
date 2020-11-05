package org.seckill.exception;

/**
 * 秒杀关闭异常(运行时异常)
 * @author Administrator
 *
 */
public class SeckillCloseException extends SeckillException{

	public SeckillCloseException(String message) {
		super(message);
	}

	public SeckillCloseException(String message, Throwable cause) {
		super(message, cause);
	}
	
	
	
	
}
