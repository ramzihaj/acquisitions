import 'dotenv/config';

import { neon, neonConfig } from '@neondatabase/serverless';
import { drizzle } from 'drizzle-orm/neon-http';

// Configure Neon to use local proxy in development
if (process.env.NODE_ENV === 'development') {
  neonConfig.fetchEndpoint = 'http://neon-local:5432/sql';
  neonConfig.useSecureWebSocket = false;
  neonConfig.wsProxy = host => `${host}:5432/v1`;
  neonConfig.pipelineTLS = false;
  neonConfig.pipelineConnect = false;
}

const sql = neon(process.env.DATABASE_URL);

const db = drizzle(sql);

export { db, sql };