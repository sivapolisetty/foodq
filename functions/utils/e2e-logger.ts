/**
 * E2E Request Tracking Logger for Cloudflare Workers
 * Correlates frontend and backend logging using X-E2E-Request-ID header
 * Sends logs to Grafana Faro collector for unified observability
 */

export interface LogContext {
  endpoint?: string;
  method?: string;
  userId?: string;
  businessId?: string;
  orderId?: string;
  error?: any;
  duration?: number;
  statusCode?: number;
  [key: string]: any;
}

interface FaroLogPayload {
  logs: Array<{
    timestamp: string;
    level: string;
    message: string;
    context: Record<string, any>;
  }>;
  meta: {
    app: {
      name: string;
      version: string;
      environment: string;
    };
    session: {
      id: string;
    };
  };
}

export class E2ELogger {
  private e2eRequestId: string;
  private startTime: number;
  private faroCollectorUrl?: string;
  private faroApiKey?: string;

  constructor(request: Request, env?: any) {
    this.e2eRequestId = request.headers.get('X-E2E-Request-ID') || 'unknown';
    this.startTime = Date.now();
    
    // Get Faro configuration from environment
    this.faroCollectorUrl = env?.GRAFANA_FARO_COLLECTOR_URL;
    this.faroApiKey = env?.GRAFANA_FARO_API_KEY;
  }

  /**
   * Send log to Grafana Faro collector
   */
  private async sendToFaro(level: string, message: string, context: LogContext = {}) {
    if (!this.faroCollectorUrl || !this.faroApiKey) {
      return; // Skip if Faro is not configured
    }

    try {
      const payload: FaroLogPayload = {
        logs: [{
          timestamp: new Date().toISOString(),
          level,
          message,
          context: {
            e2eRequestId: this.e2eRequestId,
            component: 'cloudflare-worker',
            ...context
          }
        }],
        meta: {
          app: {
            name: 'FoodQ-Backend',
            version: '1.0.0',
            environment: 'development'
          },
          session: {
            id: this.e2eRequestId
          }
        }
      };

      await fetch(this.faroCollectorUrl, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${this.faroApiKey}`
        },
        body: JSON.stringify(payload)
      });
    } catch (error) {
      // Don't let logging errors break the application
      console.error('Failed to send log to Faro:', error);
    }
  }

  /**
   * Log API request start
   */
  logRequestStart(method: string, endpoint: string, context: LogContext = {}) {
    const logData = {
      level: 'info',
      message: `API Request Started: ${method} ${endpoint}`,
      e2eRequestId: this.e2eRequestId,
      timestamp: new Date().toISOString(),
      method,
      endpoint,
      ...context
    };

    console.log(`[${this.e2eRequestId}] 🚀 API START: ${method} ${endpoint}`, logData);
    
    // Send to Faro
    this.sendToFaro('info', `API Request Started: ${method} ${endpoint}`, {
      method,
      endpoint,
      ...context
    });
  }

  /**
   * Log API request completion
   */
  logRequestEnd(method: string, endpoint: string, statusCode: number, context: LogContext = {}) {
    const duration = Date.now() - this.startTime;
    const level = statusCode >= 400 ? 'error' : 'info';
    
    const logData = {
      level,
      message: `API Request Completed: ${method} ${endpoint} - ${statusCode}`,
      e2eRequestId: this.e2eRequestId,
      timestamp: new Date().toISOString(),
      method,
      endpoint,
      statusCode,
      duration,
      ...context
    };

    const emoji = statusCode >= 400 ? '❌' : '✅';
    console.log(`[${this.e2eRequestId}] ${emoji} API END: ${method} ${endpoint} - ${statusCode} (${duration}ms)`, logData);
    
    // Send to Faro
    this.sendToFaro(level, `API Request Completed: ${method} ${endpoint} - ${statusCode}`, {
      method,
      endpoint,
      statusCode,
      duration,
      ...context
    });
  }

  /**
   * Log database operations
   */
  logDatabaseQuery(operation: string, table: string, context: LogContext = {}) {
    const logData = {
      level: 'info',
      message: `Database Query: ${operation} ${table}`,
      e2eRequestId: this.e2eRequestId,
      timestamp: new Date().toISOString(),
      operation,
      table,
      ...context
    };

    console.log(`[${this.e2eRequestId}] 🗄️ DB: ${operation} ${table}`, logData);
  }

  /**
   * Log authentication operations
   */
  logAuthOperation(operation: string, userId?: string, context: LogContext = {}) {
    const logData = {
      level: 'info',
      message: `Auth Operation: ${operation}`,
      e2eRequestId: this.e2eRequestId,
      timestamp: new Date().toISOString(),
      operation,
      userId,
      ...context
    };

    console.log(`[${this.e2eRequestId}] 🔐 AUTH: ${operation}${userId ? ` (${userId})` : ''}`, logData);
  }

  /**
   * Log business logic operations
   */
  logBusinessLogic(operation: string, context: LogContext = {}) {
    const logData = {
      level: 'info',
      message: `Business Logic: ${operation}`,
      e2eRequestId: this.e2eRequestId,
      timestamp: new Date().toISOString(),
      operation,
      ...context
    };

    console.log(`[${this.e2eRequestId}] 🏪 BUSINESS: ${operation}`, logData);
  }

  /**
   * Log errors with full context
   */
  logError(operation: string, error: any, context: LogContext = {}) {
    const logData = {
      level: 'error',
      message: `Error in ${operation}: ${error.message || error}`,
      e2eRequestId: this.e2eRequestId,
      timestamp: new Date().toISOString(),
      operation,
      error: {
        message: error.message,
        name: error.name,
        stack: error.stack,
      },
      ...context
    };

    console.error(`[${this.e2eRequestId}] 💥 ERROR: ${operation}`, logData);
    
    // Send to Faro
    this.sendToFaro('error', `Error in ${operation}: ${error.message || error}`, {
      operation,
      error: {
        message: error.message,
        name: error.name,
        stack: error.stack,
      },
      ...context
    });
  }

  /**
   * Log validation failures
   */
  logValidationError(field: string, value: any, reason: string, context: LogContext = {}) {
    const logData = {
      level: 'warn',
      message: `Validation Failed: ${field} - ${reason}`,
      e2eRequestId: this.e2eRequestId,
      timestamp: new Date().toISOString(),
      field,
      value: typeof value === 'string' ? value : JSON.stringify(value),
      reason,
      ...context
    };

    console.warn(`[${this.e2eRequestId}] ⚠️ VALIDATION: ${field} - ${reason}`, logData);
  }

  /**
   * Get the current E2E Request ID
   */
  getRequestId(): string {
    return this.e2eRequestId;
  }

  /**
   * Get request duration so far
   */
  getDuration(): number {
    return Date.now() - this.startTime;
  }

  /**
   * Create response headers including E2E Request ID
   */
  getResponseHeaders(corsHeaders: Record<string, string> = {}): Record<string, string> {
    return {
      ...corsHeaders,
      'X-E2E-Request-ID': this.e2eRequestId,
      'X-API-Version': '1.0.0',
      'X-Timestamp': new Date().toISOString(),
    };
  }
}

/**
 * Utility function to create logger from request
 */
export function createE2ELogger(request: Request, env?: any): E2ELogger {
  return new E2ELogger(request, env);
}

/**
 * Middleware to wrap API handlers with logging
 */
export function withE2ELogging<T extends any[], R>(
  handler: (...args: T) => Promise<Response>,
  operationName: string
) {
  return async (...args: T): Promise<Response> => {
    const request = args[0] as Request;
    const logger = createE2ELogger(request);
    
    const url = new URL(request.url);
    logger.logRequestStart(request.method, url.pathname);

    try {
      const response = await handler(...args);
      logger.logRequestEnd(request.method, url.pathname, response.status);
      
      // Add E2E headers to response
      const newHeaders = new Headers(response.headers);
      Object.entries(logger.getResponseHeaders()).forEach(([key, value]) => {
        newHeaders.set(key, value);
      });
      
      return new Response(response.body, {
        status: response.status,
        statusText: response.statusText,
        headers: newHeaders,
      });
    } catch (error) {
      logger.logError(operationName, error);
      throw error;
    }
  };
}