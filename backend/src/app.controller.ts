import { Controller, Get, VERSION_NEUTRAL } from '@nestjs/common';
import { AppService } from './app.service';

// Keep the root liveness endpoint reachable at `/` (unversioned). URI
// versioning with `defaultVersion: '1'` is enabled in main.ts so the feature
// controllers resolve under `/api/v1/*`; marking this controller VERSION_NEUTRAL
// preserves the pre-existing `GET /` -> 200 behavior instead of moving it to
// `/v1`. [Companion to QA FINAL Issue #1 versioning fix — behavior-preserving.]
@Controller({ version: VERSION_NEUTRAL })
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Get()
  getHello(): string {
    return this.appService.getHello();
  }
}
