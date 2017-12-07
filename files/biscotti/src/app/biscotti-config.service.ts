import { Injectable } from '@angular/core';
import {
  HttpClient,
  HttpHeaders,
  HttpHeaderResponse,
  HttpErrorResponse,
  HttpEventType,
  HttpResponse,
} from '@angular/common/http';

import { Observable } from 'rxjs/Observable';
import { BehaviorSubject } from 'rxjs/BehaviorSubject';
import 'rxjs/add/operator/map';

import { BiscottiConfig } from './biscotti-config.type';

@Injectable()
export class BiscottiConfigService {
  public config = new BehaviorSubject<BiscottiConfig>(new BiscottiConfig('', '', '', '', true));
  public error = new BehaviorSubject<any>(null);

  constructor(
    private http: HttpClient
  ) {
    this.initializeConfig();
  }

  initializeConfig() {
   this.updateConfig();
  }

  updateConfig() {
    this.getConfig().subscribe(
      configData => this.config.next(configData),
      err => this.error.next(err)
    );
  }

  private getConfig(): Observable<BiscottiConfig> {
    return this
      .http
      .get('/biscotti/config', {
        observe: 'body',
        responseType: 'json'
      })
      .map(res => {
        return new BiscottiConfig(
          res['message'],
          res['uuid_type'],
          res['doc_href'],
          res['cloud_marketplace'],
          res['auth_required']
        );
      });
  }
}
