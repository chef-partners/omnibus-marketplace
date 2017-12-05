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
import 'rxjs/add/operator/do';

import { AuthRequest } from './biscotti-auth/auth-request.type';

@Injectable()
export class BiscottiAuthService {
  public token = new BehaviorSubject<string>('');

  constructor(
    private http: HttpClient
  ) {
  }

  authorize(form: AuthRequest): Observable<string> {
    return this
      .http
      .post('/biscotti/setup/authorize', form, {
        headers: new HttpHeaders({
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        }),
        responseType: 'json',
        observe: 'body'
      })
      .map(res => res['token'])
      .do(tok => this.token.next(tok));
  }
}
