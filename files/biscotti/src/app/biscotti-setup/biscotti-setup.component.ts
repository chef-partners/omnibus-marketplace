import {
  Component,
  OnInit,
} from '@angular/core';

import {
  FormsModule,
  FormBuilder,
  FormControl,
  FormGroup,
  Validators
} from '@angular/forms';

import { saveAs } from 'file-saver';

import { MatSnackBar } from '@angular/material';

import { StarterKitForm } from './biscotti-starter-kit-form.type';
import { StarterKitService } from '../starter-kit.service';
import { BiscottiConfig } from '../biscotti-config.type';
import { BiscottiConfigService } from '../biscotti-config.service';
import { BiscottiAuthService } from '../biscotti-auth.service';

@Component({
  selector: 'app-biscotti-setup',
  templateUrl: './biscotti-setup.component.html',
  styleUrls: ['./biscotti-setup.component.scss']
})
export class BiscottiSetupComponent implements OnInit {
  public model: StarterKitForm;
  public submitted = false;
  public createComplete = false;
  public createError = false;
  public downloadComplete = false;
  public confirmPassword: boolean;
  public starterKit: Blob;
  public config: BiscottiConfig;

  constructor(
    private starterKitService: StarterKitService,
    private authService: BiscottiAuthService,
    private configService: BiscottiConfigService,
    private snackBar: MatSnackBar
  ) {}

  ngOnInit() {
    this.model = {
      firstname: '',
      lastname: '',
      email: '',
      username: '',
      organization: 'default',
      password: '',
      pubkey: '',
      supportaccount: false,
      eula: false,
      token: ''
    };
    this.configService.config.subscribe(c => this.config = c);
    this.authService.token.subscribe(t => this.model.token = t);
  }

  onSubmit(form) {
    this.submitted = true;
    this
      .starterKitService
      .createStarterKit(this.model)
      .subscribe(
        body => {
          this.createComplete = true;
          this.starterKit = body;
        },
        err => {
          let msg = '';
          if (err.error instanceof Error) {
            // A client-side or network error occurred.
            msg = `Client Error: ${err.error.message}`;
          } else {
            // The backend returned an unsuccessful response code.
            msg = `Backend Error: ${err.status} ${err.statusText}`;
          }
          this.notifyError(msg, 'Failed to create starter kit');
          // re-create the setup form by setting submitted to false
          this.submitted = false;
        }
      );
  }

  notifyError(message: string, action: string) {
    this.snackBar.open(message, action, {
      duration: 4000,
    });
  }

  downloadStarterKit() {
    this.downloadComplete = true;
    saveAs(this.starterKit, 'starter-kit.zip');
  }

  redirectToLogin() {
    window.location.replace('/e/default/#/dashboard');
  }
}
